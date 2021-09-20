[BotW_GUIAspectRatio_V208]
moduleMatches = 0x6267BFD0

.origin = codecave

const_AspectRatio:
.float ((16/9)/(1/1)) ; oculus quest 2 aspect ratio

const_434:
.float -520

; Panes from MainScreen
str_HeartGauge:
.string "Pa_HeartGauge_00"
.byte 0
str_Ability1:
.string "Pa_SinJu_00"
.byte 0
str_Ability2:
.string "Pa_SinJu_01"
.byte 0
str_Ability3:
.string "Pa_SinJu_02"
.byte 0
str_Ability4:
.string "Pa_SinJu_03"
.byte 0
str_LocationName:
.string "Pa_LocationName_00"
.byte 0
str_LocationNameS:
.string "Pa_LocationNameS_00"
.byte 0
str_TemperatureGauge:
.string "Pa_TempMeter_00"
.byte 0
str_SoundGauge:
.string "Pa_SoundGauge_00"
.byte 0
str_NearbySensor:
.string "Pa_Sensor_00"
.byte 0
str_WeatherWidget:
.string "Pa_Weather_00"
.byte 0
str_TimeWidget:
.string "Pa_Time_00"
.byte 0
str_DpadActions:
.string "Pa_PlayerStatusUp_00"
.byte 0
str_Unknown:
.string "N_Pos_00" ; check whether this one actually does anything/is breaking anything
.byte 0
str_CooldownMeter:
.string "Pa_Gauge_00"
.byte 0
str_Unknown2:
.string "Pa_CameraPointer_00"
.byte 0
str_Unknown3:
.string "Pa_ThrowingPointer_00"
.byte 0
.align 4


_compareString:
addi r5, r31, 0x80 ; address to first character of the pane name that's getting loaded

startCompare:
lbz r9, 0(r5)
lbz r12, 0(r10)

cmpwi r9, 0
bne checkForMatch
cmpwi r12, 0
bne checkForMatch
li r5, 1
blr

checkForMatch:
cmpw r9, r12
bne noMatch
addi r5, r5, 1
addi r10, r10, 1
b startCompare

noMatch:
li r5, 0
blr

; free registers = r12, r10, r9, r11, r8 maybe
; r31 has the name of the pane at an offset at 0x80
_scalePaneGUI:
mflr r0

addi r5, r31, 0x80
lbz r10, 3(r5)
cmpwi r10, 0x48 ; H
;bne exitScale

lis r10, str_HeartGauge@ha
addi r10, r10, str_HeartGauge@l
bla _compareString
cmpwi r5, 1
beq scalePaneHearts

lis r10, str_Ability1@ha
addi r10, r10, str_Ability1@l
bla _compareString
cmpwi r5, 1
beq scalePaneNormal

lis r10, str_Ability2@ha
addi r10, r10, str_Ability2@l
bla _compareString
cmpwi r5, 1
beq scalePaneNormal

lis r10, str_Ability3@ha
addi r10, r10, str_Ability3@l
bla _compareString
cmpwi r5, 1
beq scalePaneNormal

lis r10, str_Ability4@ha
addi r10, r10, str_Ability4@l
bla _compareString
cmpwi r5, 1
beq scalePaneNormal

lis r10, str_LocationName@ha
addi r10, r10, str_LocationName@l
bla _compareString
cmpwi r5, 1
beq scalePaneNormal

lis r10, str_LocationNameS@ha
addi r10, r10, str_LocationNameS@l
bla _compareString
cmpwi r5, 1
beq scalePaneNormal

lis r10, str_TemperatureGauge@ha
addi r10, r10, str_TemperatureGauge@l
bla _compareString
cmpwi r5, 1
beq scalePaneNormal

lis r10, str_SoundGauge@ha
addi r10, r10, str_SoundGauge@l
bla _compareString
cmpwi r5, 1
beq scalePaneNormal

lis r10, str_NearbySensor@ha
addi r10, r10, str_NearbySensor@l
bla _compareString
cmpwi r5, 1
beq scalePaneNormal

lis r10, str_WeatherWidget@ha
addi r10, r10, str_WeatherWidget@l
bla _compareString
cmpwi r5, 1
beq scalePaneNormal

lis r10, str_TimeWidget@ha
addi r10, r10, str_TimeWidget@l
bla _compareString
cmpwi r5, 1
beq scalePaneNormal

lis r10, str_DpadActions@ha
addi r10, r10, str_DpadActions@l
bla _compareString
cmpwi r5, 1
beq scalePaneNormal

lis r10, str_Unknown@ha
addi r10, r10, str_Unknown@l
bla _compareString
cmpwi r5, 1
beq scalePaneNormal

lis r10, str_CooldownMeter@ha
addi r10, r10, str_CooldownMeter@l
bla _compareString
cmpwi r5, 1
beq scalePaneNormal

lis r10, str_Unknown2@ha
addi r10, r10, str_Unknown2@l
bla _compareString
cmpwi r5, 1
beq scalePaneNormal

lis r10, str_Unknown3@ha
addi r10, r10, str_Unknown3@l
bla _compareString
cmpwi r5, 1
beq scalePaneNormal

; If nothing matched, exit without setting the size or position of this pane
b exitScale

; Divides the width of this element with the change in aspect ratio
scalePaneNormal:
lis r10, const_AspectRatio@ha
lfs f0,  const_AspectRatio@l(r10)
stfs f0, 0x34(r31)
b exitScale

; Changes the width of this element but also moves them proportionally
scalePaneHearts:
lis r10, const_434@ha
lfs f9, const_434@l(r10)
;stfs f9, 0x1C(r31)
lis r10, const_AspectRatio@ha
lfs f0,  const_AspectRatio@l(r10)
stfs f0, 0x34(r31)
b exitScale

exitScale:
mtlr r0
lwz r0, 0x24(r30)
blr

0x03C496B8 = bla _scalePaneGUI