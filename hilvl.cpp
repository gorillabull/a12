#include <iostream>

using namespace std; 
void i2q(int);

int main(){
    i2q(4788);


    char num[] = {'1','2','3','1','2','3',0};

    int b10Num =0;  //number in b10 
    //convert to base 10 

    int rem = 0 ;
    int b = 1;
    int pMul = 5; 
    int iter = 5 ; //ch count -1 for null 

    while(iter >-1 ){
        rem = num[iter]-48;
        cout<<rem;
        b10Num += rem * b ; 
        b=b*pMul;               //next power 
        iter--;
    }
    cout<<endl;
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