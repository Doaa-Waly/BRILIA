%analyzeEdges will look at the alignment near the 5' and 3' edges with
%respect the 104C and 118W positions to determine if the mutations are
%unreasonably high, caused by sequencing erros. 
%
%  INPUT
%    VDJdata: BRILIA table storing sequence annotatoing data
%    VDJheader: header name of the VDJdata
%    
%  OUTPUT
%    EdgeAnalysis: Data storing the number of mutations as a distance from
%      the 
%  
function EdgeAnalysis = analyzeEdges(VDJdata, VDJheader)
