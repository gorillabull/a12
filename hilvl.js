function hyperPerfect() {
    var k = 2;
    for (var i = 2; i <= 500000; i++) {
        var arr = getDivisors(i);
        var sumArr = sumDivisors(arr);

        var rhs = (1 + 2 * (sumArr - 1));
        if (i == rhs ) {
            console.log(i.toString());
        }
    }
}


function sumDivisors(arr) {
    var sum = 0;
    for (var i = 0; i < arr.length; i++) {
        sum += arr[i];
    }

    return sum;
}

function getDivisors(  n) {
    var rett = [];
    for (var i = 1; i < n; i++) {
        if (n%i===0) {
            rett.push(i);
        }
    }
    return rett; 
}