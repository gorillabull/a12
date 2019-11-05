
var I = 2;

function hyperPerfect() {
 
    

    while(I<=4788){
        
        var sumArr = 0 ;
        var rhs =0;

        for (var i = 1; i < I; i++) {
            if (I%i===0) {
                sumArr +=i ;
            }
        }
        
         rhs = sumArr-1; // (1 + 2 * (sumArr - 1));
         rhs = rhs*2;
         rhs+=1;
        
        if (I == rhs ) {

            console.log(I.toString());
            //inc hpCount 
        }
        
        I++;
    }
}

 