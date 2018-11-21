wipe
# system
model BasicBuilder -ndm 3 -ndf 6
# unit mm s kg
# node 111 第1层第1榀框架1节点
node 111 0.000e+0 0.000e+0 0.000e+0
node 112 2.720e+3 0.000e+0 0.000e+0
node 121 0.000e+0 2.720e+3 0.000e+0
node 122 2.720e+3 2.720e+3 0.000e+0
node 211 0.000e+0 0.000e+0 3.300e+3
node 212 2.720e+3 0.000e+0 3.300e+3
node 221 0.000e+0 2.720e+3 3.300e+3
node 222 2.720e+3 2.720e+3 3.300e+3
node 311 0.000e+0 0.000e+0 6.600e+3
node 312 2.720e+3 0.000e+0 6.600e+3
node 321 0.000e+0 2.720e+3 6.600e+3
node 322 2.720e+3 2.720e+3 6.600e+3
# restraint
fix 111 1 1 1 1 1 1
fix 112 1 1 1 1 1 1 
fix 121 1 1 1 1 1 1
fix 122 1 1 1 1 1 1
# material
set SteMat 1
set CovConMat 2
set BeamCoreConMat 3
set ColCoreConMat 4
uniaxialMaterial Steel02 $SteMat 335 200000 0.01 20 0.925 0.15
uniaxialMaterial Concrete01 $CovConMat -26.8 -0.0020 -5.36 -0.0033
uniaxialMaterial Concrete01 $BeamCoreConMat -29.7 -0.0021 -5.94 -0.0033
uniaxialMaterial Concrete01 $ColCoreConMat -31.0 -0.0023 -6.2 -0.0033
uniaxialMaterial Elastic 101 838125000
uniaxialMaterial Elastic 102 838125000
uniaxialMaterial Elastic 103 204000000000000
# beam
section Fiber 1 {
    patch rect $BeamCoreConMat 5 9 -62 -112 62 102

    patch rect $CovConMat 9 2 -100 102 100 150
    patch rect $CovConMat 9 2 -100 -150 100 -112
    patch rect $CovConMat 2 9 -100 -112 -62 102
    patch rect $CovConMat 2 9 62 -112 100 102

    layer straight $SteMat 4 113.04 -62 -112 62 -112
    layer straight $SteMat 4 113.04 -62 112 62 112
    layer straight $SteMat 2 113.04 -62 12 62 12
}
set BeamSec 1001
section Aggregator $BeamSec 101 Vy 102 Vz 103 T -section 1
# column
#section RCSection2d 2 4 2 1 350 350 28 615.44 615.44 615.44 100 44 1
section Fiber 2 {
    patch rect $ColCoreConMat 16 16 -140 -140 140 140

    patch rect $CovConMat 20 2 -175 140 175 175
    patch rect $CovConMat 20 2 -175 -175 175 -140
    patch rect $CovConMat 2 9 -175 -140 -140 140
    patch rect $CovConMat 2 9 140 -140 175 140

    layer straight $SteMat 4 153.86 -140 -140 140 -140
    layer straight $SteMat 4 153.86 -140 140 140 140
    layer straight $SteMat 2 153.86 -140 -33 140 -33
    layer straight $SteMat 2 153.86 -140 33 140 33
}
set ColSec 2001
section Aggregator $ColSec 101 Vy 102 Vz 103 T -section 2
# transformation
# 单元类型
set BeamTra 1
set GirdTra 2
set ColTra 3
geomTransf Linear $BeamTra 0 0 1
geomTransf Linear $GirdTra 0 0 1
geomTransf PDelta $ColTra 0 1 0 
# element 211 单元类型编号+第1层第1个
element nonlinearBeamColumn 111 211 221 5 $BeamSec $BeamTra -mass 186
element nonlinearBeamColumn 112 212 222 5 $BeamSec $BeamTra -mass 186
element nonlinearBeamColumn 121 311 321 5 $BeamSec $BeamTra -mass 186
element nonlinearBeamColumn 122 312 322 5 $BeamSec $BeamTra -mass 186
element nonlinearBeamColumn 211 211 212 5 $BeamSec $GirdTra -mass 186
element nonlinearBeamColumn 212 221 222 5 $BeamSec $GirdTra -mass 186
element nonlinearBeamColumn 221 311 312 5 $BeamSec $GirdTra -mass 186
element nonlinearBeamColumn 222 321 322 5 $BeamSec $GirdTra -mass 186
element nonlinearBeamColumn 311 111 211 5 $ColSec $ColTra -mass 367.5
element nonlinearBeamColumn 312 112 212 5 $ColSec $ColTra -mass 367.5
element nonlinearBeamColumn 313 121 221 5 $ColSec $ColTra -mass 367.5
element nonlinearBeamColumn 314 122 222 5 $ColSec $ColTra -mass 367.5
element nonlinearBeamColumn 321 211 311 5 $ColSec $ColTra -mass 367.5
element nonlinearBeamColumn 322 212 312 5 $ColSec $ColTra -mass 367.5
element nonlinearBeamColumn 323 221 321 5 $ColSec $ColTra -mass 367.5
element nonlinearBeamColumn 324 222 322 5 $ColSec $ColTra -mass 367.5
# recorlder
recorder Node -file node311.out -time -node 311 -dof 1 2 3 disp 
recorder Node -file node.out -time -node 211 -dof 1 2 3 disp
# gravity
pattern Plain 1 Linear {
    eleLoad -ele 111 112 121 122 211 212 221 222 -type -beamUniform 0.000 -1000000
    #eleLoad -ele 9 10 11 12 13 14 15 16 -type -beamUniform 0.000 -1.5
    #load 311 0 1000 0 0 0 0
}
# analysis
constraints Plain
numberer Plain
system BandGeneral
test EnergyIncr 1.0e-6 200
algorithm Newton
integrator LoadControl 0.1
analysis Static
analyze 10

loadConst -time 0.0 

set xDamp 0.05;
set nEigenI 1;
set nEigenJ 2;
set lambdaN [eigen [expr $nEigenJ]];
set lambdaI [lindex $lambdaN [expr $nEigenI-1]];
set lambdaJ [lindex $lambdaN [expr $nEigenJ-1]];
set omegaI [expr pow($lambdaI,0.5)]; 
set omegaJ [expr pow($lambdaJ,0.5)];
set alphaM [expr $xDamp*(2*$omegaI*$omegaJ)/($omegaI+$omegaJ)]; 
set betaKcurr [expr 2.*$xDamp/($omegaI+$omegaJ)];   
rayleigh $alphaM $betaKcurr 0 0  
  
set IDloadTag 1001;
set iGMfile "GM1X.txt";
set iGMdirection "1"; 
set iGMfact "0.6072";  
set dt 0.02;   
foreach GMdirection $iGMdirection GMfile $iGMfile GMfact $iGMfact { 
incr IDloadTag; 
set GMfatt [expr 1*$GMfact];  
set AccelSeries "Series -dt $dt -filePath $iGMfile -factor  $GMfatt";
pattern UniformExcitation  $IDloadTag  $GMdirection -accel  $AccelSeries; 
}  
  
constraints Transformation; 
numberer Plain;  
system UmfPack; 
test NormDispIncr  1.0e-1 1000; 
algorithm Newton 
integrator Newmark 0.5 0.25 
analysis Transient
analyze 3000 0.005
