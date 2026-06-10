/*********************************************
 * OPL 22.1.0.0 Model
 * Author: Razieh Enayatsefat
 * 
 *********************************************/

int Nsample = ...; 
int Nlocus = ...; 
int Nstate = ...;
 
range sample = 1..Nsample;
range locus = 1..Nlocus;
range state = 0..Nstate-1;

int M [1..Nlocus*Nstate*Nlocus*Nstate] = ...;
int Q [1..Nlocus*Nstate*Nlocus*Nstate] = ...;
float T [1..Nsample*Nlocus*Nstate] = ...;

float f[sample][locus][state];

int z[locus][state][locus][state];
int u[locus][state][locus][state];

execute{
  var count = 0; 
  for (var i in locus){
    for (var j in state){
      for (var k in locus){
        for (var l in state){
          count = count + 1;

            u[i][j][k][l] = M[count]; 
            z[i][j][k][l] = Q[count]; 
          
            z[1][0][k][l] = 1;
            u[1][0][k][l] = 1;
            u[1][0][k][0] = 0;
            z[i][j][i][j] = 1;
         
        };
      };
    };
  };
  /*
//u,z
z[1][0][1][1] = 1;
z[1][0][1][2] = 1;
z[1][0][2][3] = 1;
z[1][0][3][4] = 1;
z[1][0][4][0] = 1;
z[1][0][4][5] = 1;
z[1][0][5][0] = 1;
z[1][1][1][2] = 1;
z[3][4][4][5] = 1;
z[4][6][1][1] = 1;
z[4][6][1][2] = 1;
z[4][6][2][3] = 1;
z[4][6][3][4] = 1;
z[4][6][4][5] = 1;
z[4][6][5][7] = 1;
z[5][7][1][1] = 1;
z[5][7][1][2] = 1;
z[5][7][4][5] = 1;
//----------------
z[1][0][1][0] = 1;
z[1][1][1][1] = 1;
z[1][2][1][2] = 1;
z[2][3][2][3] = 1;
z[3][4][3][4] = 1;
z[4][0][4][0] = 1;
z[4][5][4][5] = 1;
z[5][0][5][0] = 1;
z[4][6][4][6] = 1;
z[5][7][5][7] = 1;
//----------------
u[1][0][1][1] = 1;
u[1][0][1][2] = 1;
u[1][0][2][3] = 1;
u[1][0][3][4] = 1;
u[1][0][4][5] = 1;
u[1][1][1][2] = 1;
u[3][4][4][5] = 1;
u[4][6][1][1] = 1;
u[4][6][1][2] = 1;
u[4][6][2][3] = 1;
u[4][6][3][4] = 1;
u[4][6][4][5] = 1;
u[4][6][5][7] = 1;
u[5][7][1][1] = 1;
u[5][7][1][2] = 1;
u[5][7][4][5] = 1;
*/

}; 
 
 
 
 
 execute{
      var cc = 0;
    
    for(var i in sample){
      for(var j in locus){
        for(var k in state){
          cc = cc + 1;
          f[i][j][k] = T[cc];
        }
      }
    }
    
}


dvar boolean zz[locus][state][locus][state];

 tuple anc {
  int e;
  int r;
  int ee;
  int rr;
}
setof(anc) ancestry = {<e,r,ee,rr>|e, ee in locus , r, rr in state: z[e][r][ee][rr]==1};
setof(anc) edge = {<e,r,ee,rr>|e, ee in locus , r, rr in state: u[e][r][ee][rr]==1};

 tuple vertex {
  int e;
  int r;
}
setof(vertex) vertices={<e,r>|e in locus , r in state};


tuple root {
  int ee;
  int rr;
}
setof(root) roots=vertices diff {<ee,rr>| ee in 2..Nlocus, rr in 0..0};



dexpr int G=sum(<e,jj> in roots, <c,i> in roots: <e,jj,c,i> in edge && <e,jj>!=<1,0>)zz[e][jj][c][i];

maximize G;

subject to{
 
  cons1:
  
  forall(<c,i> in roots, p in sample)
    
     if(sum(<e,jj,c,i> in edge)z[e][jj][c][i]>=1 && sum(<c,i,d,j> in edge)z[c][i][d][j]>=1) //z dar en khat ra u kon
    
    sum(<e,jj> in roots, l in state: <e,jj,c,i> in edge && <c,i,c,l> in ancestry)  z[c][i][c][l]*f[p][c][l]* zz[e][jj][c][i] - sum(<d,j> in roots, k in state: <c,i,d,j> in edge && <d,j,d,k> in ancestry)  z[d][j][d][k]*f[p][d][k]* zz[c][i][d][j]>=0;
    
    
//    if(sum(<d,j> in vertices)z[c][i][d][j]>=1)
//   sum(l in state: <c,i,c,l> in ancestry)  z[c][i][c][l]*f[p][c][l] - sum(<d,j> in vertices, k in state: <c,i,d,j> in edge && <d,j,d,k> in ancestry)  z[d][j][d][k]*f[p][d][k]* zz[c][i][d][j]>=0;


  cons2:
   
  forall(<c,i> in roots)
    if(sum(<e,jj,c,i> in edge)z[e][jj][c][i]>=1)
   sum(<e,jj> in roots: <e,jj,c,i> in edge) zz[e][jj][c][i] <= 1;
   


//  forall(<c,i> in roots , <d,j> in roots , <e,l> in roots: <c,i,d,j> in edge && <c,i,e,l> in ancestry && <d,j,e,l> in edge && <c,i>!=<d,j> && <c,i>!=<e,l> && <d,j>!=<e,l>)
//    if(sum(<e,l> in roots)z[d][j][e][l]>=1 && sum(<d,j> in roots)z[d][j][e][l]>=1)
//   z[c][i][d][j]-z[c][i][e][l]+zz[d][j][e][l]<=1;
  
  
//  forall(<c,i> in roots, <d,j> in roots: <c,i,d,j> in edge)
//    zz[c][i][d][j] <= z[c][i][d][j];

 
   cons3:   
   forall(<c,i,d,j> in edge) 
    if(sum(<e,jj,c,i> in edge)z[e][jj][c][i]>=1)
    zz[c][i][d][j]<=sum(<e,jj> in roots: <e,jj,c,i> in edge)zz[e][jj][c][i];
  
  cons4:  
  forall(<c,i,d,j> in edge) 
   if(sum(<c,i,d,j> in edge)z[c][i][d][j]>=1 && sum(<d,j,c,i> in edge)z[d][j][c][i]>=1)
  zz[c][i][d][j] + zz[d][j][c][i] <=1;  
   
 }
 
 
 
 
 execute{
  for(var i in locus)
  for(var j in state)
  for(var k in locus)
  for(var l in state)
  if(zz[i][j][k][l]!=0)
  writeln("<",i,",",j,">","->","<",k,",",l,">")
}
 