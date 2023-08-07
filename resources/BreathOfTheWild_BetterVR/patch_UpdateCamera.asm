[BetterVR_UpdateCamera_V208]
moduleMatches = 0x6267BFD0

.origin = codecave


MEM_OFFSET_POS = 0x5C0
MEM_OFFSET_TARGET = 0x5CC

OLD_POS_STACK_OFFSET = 0x04
OLD_TARGET_STACK_OFFSET = 0x10

ENABLED_STACK_OFFSET = 0x1C
NEW_POS_STACK_OFFSET = 0x20
NEW_TARGET_STACK_OFFSET = 0x2C


updateCameraPositionAndTarget:
; repeat instructions from either branches
lfs f0, 0xEC0(r31)
stfs f0, 0x5CC(r31)
lfs f13, 0xEB8(r31)
stfs f13, 0x5C4(r31)

; function prologue
mflr r0
stwu r1, -0x58(r1)
stw r0, 0x5C(r1)

; copy memory to stack
lfs f0, MEM_OFFSET_POS+0x0(r31)
stfs f0, OLD_POS_STACK_OFFSET+0x0(r1)
lfs f0, MEM_OFFSET_POS+0x4(r31)
stfs f0, OLD_POS_STACK_OFFSET+0x4(r1)
lfs f0, MEM_OFFSET_POS+0x8(r31)
stfs f0, OLD_POS_STACK_OFFSET+0x8(r1)

lfs f0, MEM_OFFSET_TARGET+0x0(r31)
stfs f0, OLD_TARGET_STACK_OFFSET+0x0(r1)
lfs f0, MEM_OFFSET_TARGET+0x4(r31)
stfs f0, OLD_TARGET_STACK_OFFSET+0x4(r1)
lfs f0, MEM_OFFSET_TARGET+0x8(r31)
stfs f0, OLD_TARGET_STACK_OFFSET+0x8(r1)

; call method in hook
li r7, 0
stw r7, ENABLED_STACK_OFFSET(r1)
addi r7, r1, OLD_POS_STACK_OFFSET
addi r3, r1, ENABLED_STACK_OFFSET
bl import.coreinit.hook_UpdateCameraPositionAndTarget
lwz r7, ENABLED_STACK_OFFSET(r1)
cmpwi r7, 0
beq exit_updateCameraPositionAndTarget

; copy stack to memory
lfs f0, NEW_POS_STACK_OFFSET+0x0(r1)
stfs f0, MEM_OFFSET_POS+0x0(r31)
lfs f0, NEW_POS_STACK_OFFSET+0x4(r1)
stfs f0, MEM_OFFSET_POS+0x4(r31)
lfs f0, NEW_POS_STACK_OFFSET+0x8(r1)
stfs f0, MEM_OFFSET_POS+0x8(r31)

lfs f0, NEW_TARGET_STACK_OFFSET+0x0(r1)
stfs f0, MEM_OFFSET_TARGET+0x0(r31)
lfs f0, NEW_TARGET_STACK_OFFSET+0x4(r1)
stfs f0, MEM_OFFSET_TARGET+0x4(r31)
lfs f0, NEW_TARGET_STACK_OFFSET+0x8(r1)
stfs f0, MEM_OFFSET_TARGET+0x8(r31)

exit_updateCameraPositionAndTarget:
; function epilogue
lwz r0, 0x5C(r1)
mtlr r0
addi r1, r1, 0x58

addi r3, r31, 0xE78
blr


0x02C054FC = bla updateCameraPositionAndTarget
0x02C05590 = bla updateCameraPositionAndTarget


MEM_ROT_OFFSET = 0x18
ENABLED_ROT_STACK_OFFSET = 0x04
NEW_ROT_STACK_OFFSET = 0x08

updateCameraRotation:
stfs f10, 0x18(r31)

mflr r0
stwu r1, -0x14(r1)
stw r0, 0x18(r1)

li r3, 0
stw r3, ENABLED_ROT_STACK_OFFSET(r1)
addi r3, r1, 0x04
bl import.coreinit.hook_UpdateCameraRotation
lwz r3, ENABLED_ROT_STACK_OFFSET(r1)
cmpwi r3, 0
beq exit_updateCameraRotation

lfs f10, NEW_ROT_STACK_OFFSET+0x0(r1)
stfs f10, MEM_ROT_OFFSET+0x0(r31)
lfs f10, NEW_ROT_STACK_OFFSET+0x4(r1)
stfs f10, MEM_ROT_OFFSET+0x4(r31)
lfs f10, NEW_ROT_STACK_OFFSET+0x8(r1)
stfs f10, MEM_ROT_OFFSET+0x8(r31)

exit_updateCameraRotation:
lwz r0, 0x18(r1)
mtlr r0
addi r1, r1, 0x14
blr

0x02E57FF0 = bla updateCameraRotation
