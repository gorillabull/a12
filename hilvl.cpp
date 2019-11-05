#include <iostream>

using namespace std; 
void i2q(int);

int main(){
    i2q(4788);
    int num = 123123;
    int b10Num =0;  //number in b10 
    //convert to base 10 

    int rem = 0 ;
    int b = 1;
    int pMul = 5; 

    while(num >0 ){
        rem = num%10;
        num = num/10;
        
        b10Num += rem * b ; 
        b=b*pMul;               //next power 
    }

    cout<<b10Num<<endl;
    return 0;
}

void i2q(int n){
    char* str = new char[20];
    str[19]= 0;

    //init to zeroes 
    for (int i = 0; i < 19; i++)
    {
        str[i] = ' ';
    }
    
     int base =5 ;
     int rem=0 ;
     int iter = 18 ;

     while (n>0)
     {
      rem = n %5;
      n = n - rem; 
      n = n /5 ;
      str[iter] = (char)(rem+48);
      cout<<rem;
      iter--;
     }

     
     cout<<str<<endl;
        
}