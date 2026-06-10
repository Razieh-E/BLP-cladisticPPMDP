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
range state = 1..Nstate;
range ls = 1..Nlocus*Nstate;


float f[1..Nsample*Nlocus*Nstate] = ...;
int s[1..Nlocus*Nstate*Nlocus*Nstate] = ...;
float uu[1..Nstate*Nlocus*Nsample] = ...;


float F[sample][locus][state];
int st[locus][state][locus][state];
float u[locus][state][sample];
float H[sample][ls] = ...;

int z[ls][ls] = ...; //ancestor relationship

execute{
  var cccc = 0;
  for(var i in locus){
  for(var j in state){
  for(var k in sample){
  cccc = cccc + 1;
  u[i][j][k] = uu[cccc];

}
}
}  

}

execute{
      var cc = 0;
    
    for(var i in sample){
      for(var j in locus){
        for(var k in state){
          cc = cc + 1;
          F[i][j][k] = f[cc];
        }
      }
    }
         var ccc = 0;
   
   for(var i in locus){
    for(var j in state){
      for(var k in locus){
        for(var l in state){
          ccc = ccc + 1;
          st[i][j][k][l] = s[ccc];
        }
      }
    } 
  }    
}

execute{
  var d = 0;
  var dd = 0;
 for(var c in locus){
  for (var i in state){
    for (var p in sample){
       var count = 0;
      for (var j in state){

          if (st[c][i][c][j]==1){
          count = count + F[p][c][j];
        } 
                 
          d = d + 1;
            
        }
        
          u[c][i][p] = count; 
          dd = dd + 1;  
          uu[dd] = count;
    
          
      }
    }
  } 
  
}


execute{
  var j, i;

     for(j=0; j <= Nlocus*Nstate-1; j++){
      for(i=Nsample*j+1; i <= Nsample*(j+1); i++){
        H[i-Nsample*j][j+1] = uu[i];
      }
   }     

 
}


execute{
  var s,t,tt,u,v;
  for(s=1; s<=Nlocus*Nstate; s++){
  for(t=s+1; t<=Nlocus*Nstate; t++){
  for(tt=1; tt<=Nsample; tt++){
    
   if(H[tt][s] < H[tt][t]){
     z[s][t] = 0; // s=(c,i) t=(d,j)
      break;
 }
 
 if(H[tt][s] != 0 & H[tt][t] != 0){
    if(H[tt][s] >= H[tt][t]){   
    z[s][t] = 1;  
 } 
}  
  
  }    
   }
    } 
  
   for(u=Nlocus*Nstate; u>=1; u--){      
     for(v=u-1; v>=1; v--){
       for(tt=1; tt<=Nsample; tt++){
         
   if(H[tt][u] < H[tt][v]){
   z[u][v] = 0;
   break;
 }  
 
 if(H[tt][u] != 0 & H[tt][v] != 0){
  if(H[tt][u] >= H[tt][v]){   
    z[u][v]=1; 
   } 
 }    
         
       }
     }
   }            
  
}

execute{
  for(var i in ls)
  for(var j in ls)
  if(z[i][j]!=0)
  writeln(i," ",j,";")
  writeln("................")
}


execute{
var I = 0;
for(c in locus){
  for(i in state){
    I = I + 1;

var J = 0;
  for(d in locus){
  for(j in state){
    J = J + 1;
 
  if(z[I][J]!=0){
  writeln("<", c, ",", i, ">", "->", "<", d, ",", j, ">")

}  
  

  }
} 

  }
}

}














 