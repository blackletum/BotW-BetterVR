#include "cemu_hooks.h"
#include "rendering/openxr.h"
#include "instance.h"

#include <glm/glm.hpp>
#include <glm/ext/matrix_transform.hpp>
#include <glm/gtc/matrix_access.hpp>
#include <glm/gtc/quaternion.hpp>
#include <glm/gtx/projection.hpp>
#include <glm/gtx/quaternion.hpp>
#include <glm/gtc/constants.hpp>

OpenXR::EyeSide CemuHooks::s_eyeSide = OpenXR::EyeSide::LEFT;


void CemuHooks::hook_UpdateCamera(PPCInterpreter_t* hCPU) {
    //Log::print("Updated camera!");
    hCPU->instructionPointer = hCPU->gpr[7];

    // Read the camera matrix from the game's memory
    uint32_t ppc_cameraMatrixOffsetIn = hCPU->gpr[30];
    data_VRCameraIn origCameraMatrix = {};

    readMemory(ppc_cameraMatrixOffsetIn, &origCameraMatrix);
    swapEndianness(origCameraMatrix.posX);
    swapEndianness(origCameraMatrix.posY);
    swapEndianness(origCameraMatrix.posZ);
    swapEndianness(origCameraMatrix.targetX);
    swapEndianness(origCameraMatrix.targetY);
    swapEndianness(origCameraMatrix.targetZ);
    swapEndianness(origCameraMatrix.fov);

    data_VRSettingsIn settings = VRManager::instance().Hooks->GetSettings();


    // Current VR headset camera matrix
    // fixme: Update poses close to usage aka here: VRManager::instance().XR->UpdatePoses(m_eyeSide);
    XrView currView = VRManager::instance().XR->GetPredictedView(s_eyeSide);
    glm::fvec3 currEyePos(currView.pose.position.x, currView.pose.position.y, currView.pose.position.z);
    glm::fquat currEyeQuat(currView.pose.orientation.w, currView.pose.orientation.x, currView.pose.orientation.y, currView.pose.orientation.z);
    Log::print("Headset View: x={}, y={}, z={}, orientW={}, orientX={}, orientY={}, orientZ={}", currEyePos.x, currEyePos.y, currEyePos.z, currEyeQuat.w, currEyeQuat.x, currEyeQuat.y, currEyeQuat.z);

    // Current in-game camera matrix
    glm::fvec3 oldCameraPosition(origCameraMatrix.posX, origCameraMatrix.posY, origCameraMatrix.posZ);
    glm::fvec3 oldCameraTarget(origCameraMatrix.targetX, origCameraMatrix.targetY, origCameraMatrix.targetZ);
    float oldCameraDistance = glm::distance(oldCameraPosition, oldCameraTarget);
    Log::print("Original Game Camera: x={}, y={}, z={}, targetX={}, targetY={}, targetZ={}", oldCameraPosition.x, oldCameraPosition.y, oldCameraPosition.z, oldCameraTarget.x, oldCameraTarget.y, oldCameraTarget.z);

    // Calculate game view directions
    glm::fvec3 forwardVector = glm::normalize(oldCameraTarget - oldCameraPosition);
    glm::fquat lookAtQuat = glm::quatLookAtRH(forwardVector, {0.0, 1.0, 0.0});

    // Calculate new view direction
    glm::fquat combinedQuat = glm::normalize(lookAtQuat * currEyeQuat);
    glm::fmat3 combinedMatrix = glm::toMat3(combinedQuat);

    // Calculate the camera rotation
    glm::fvec3 rotatedHmdPos = combinedQuat * currEyePos;

    // Convert the calculated parameters into the new camera matrix provided by the game
    data_VRCameraOut updatedCameraMatrix = {
        .posX = oldCameraPosition.x + rotatedHmdPos.x,
        .posY = oldCameraPosition.y + rotatedHmdPos.y + settings.heightPositionOffsetSetting,
        .posZ = oldCameraPosition.z + rotatedHmdPos.z,
        .targetX = oldCameraPosition.x + ((combinedMatrix[2][0] * -1.0f) * oldCameraDistance) + rotatedHmdPos.x,
        .targetY = oldCameraPosition.y + ((combinedMatrix[2][1] * -1.0f) * oldCameraDistance) + rotatedHmdPos.y + settings.heightPositionOffsetSetting,
        .targetZ = oldCameraPosition.z + ((combinedMatrix[2][2] * -1.0f) * oldCameraDistance) + rotatedHmdPos.z,
        .rotX = combinedMatrix[1][0],
        .rotY = combinedMatrix[1][1],
        .rotZ = combinedMatrix[1][2],
        .fov = origCameraMatrix.fov,
        .aspectRatio = 0.872665f
    };

    // Write the camera matrix to the game's memory
    Log::print("New Game Camera: x={}, y={}, z={}, targetX={}, targetY={}, targetZ={}, rotX={}, rotY={}, rotZ={}", updatedCameraMatrix.posX, updatedCameraMatrix.posY, updatedCameraMatrix.posZ, updatedCameraMatrix.targetX, updatedCameraMatrix.targetY, updatedCameraMatrix.targetZ, updatedCameraMatrix.rotX, updatedCameraMatrix.rotY, updatedCameraMatrix.rotZ);
    swapEndianness(updatedCameraMatrix.posX);
    swapEndianness(updatedCameraMatrix.posY);
    swapEndianness(updatedCameraMatrix.posZ);
    swapEndianness(updatedCameraMatrix.targetX);
    swapEndianness(updatedCameraMatrix.targetY);
    swapEndianness(updatedCameraMatrix.targetZ);
    swapEndianness(updatedCameraMatrix.rotX);
    swapEndianness(updatedCameraMatrix.rotY);
    swapEndianness(updatedCameraMatrix.rotZ);
    swapEndianness(updatedCameraMatrix.fov);
    swapEndianness(updatedCameraMatrix.aspectRatio);
    uint32_t ppc_cameraMatrixOffsetOut = hCPU->gpr[31];
    writeMemory(ppc_cameraMatrixOffsetOut, &updatedCameraMatrix);
}