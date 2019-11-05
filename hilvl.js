
var I = 2;

function hyperPerfect() {
 

    while(I<=500000){
        //var sumArr = getDivisors(I);
        var sumArr = 0 ;
        for (var i = 1; i < I; i++) {
            if (I%i===0) {
                sumArr +=i ;
            }
        }
        
        var rhs = (1 + 2 * (sumArr - 1));
        if (I == rhs ) {

            console.log(I.toString());
        }
        //lock and unlock this part
        I++;
    }
}

function getDivisors(  n) {
    var rett = [];
    var sum =0 ;


    return sum 
}