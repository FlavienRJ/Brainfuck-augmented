#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>

int TapeArray[1024] = {0};
int head = 512;
int i = 0 ;

int main ( int argc, char *argv[] ){
	 TapeArray[head]+=8;
	 i = head;
	 while (!TapeArray[i]) {
	 head+=1;
	 TapeArray[head]+=4;
	 i = head;
	 while (!TapeArray[i]) {
	 head+=1;
	 TapeArray[head]+=2;
	 head+=1;
	 TapeArray[head]+=3;
	 head+=1;
	 TapeArray[head]+=3;
	 head+=1;
	 TapeArray[head]+=1;
	 head-=4;
	 TapeArray[head]-=1;
	 }
	 head+=1;
	 TapeArray[head]+=1;
	 head+=1;
	 TapeArray[head]+=1;
	 head+=1;
	 TapeArray[head]-=1;
	 head+=2;
	 TapeArray[head]+=1;
	 i = head;
	 while (!TapeArray[i]) {
	 head-=1;
	 }
	 head-=1;
	 TapeArray[head]-=1;
	 }
	 head+=2;
	 printf("%c \n ",TapeArray[head]);
	 head+=1;
	 TapeArray[head]-=3;
	 printf("%c \n ",TapeArray[head]);
	 TapeArray[head]+=7;
	 printf("%c \n ",TapeArray[head]);
	 TapeArray[head]+=3;
	 printf("%c \n ",TapeArray[head]);
	 head+=2;
	 printf("%c \n ",TapeArray[head]);
	 head-=1;
	 TapeArray[head]-=1;
	 printf("%c \n ",TapeArray[head]);
	 head-=1;
	 printf("%c \n ",TapeArray[head]);
	 TapeArray[head]+=3;
	 printf("%c \n ",TapeArray[head]);
	 TapeArray[head]-=6;
	 printf("%c \n ",TapeArray[head]);
	 TapeArray[head]-=8;
	 printf("%c \n ",TapeArray[head]);
	 head+=2;
	 TapeArray[head]+=1;
	 printf("%c \n ",TapeArray[head]);
	 head+=1;
	 TapeArray[head]+=2;
 return 0; 
 }