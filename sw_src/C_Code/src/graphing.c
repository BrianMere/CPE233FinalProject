
// Sample functionality (as provided by Hummel :)

// int sum(int x, int y)
// {
// 	return x+y;
// }
// void main()
// {
// 	int total=0;
// 	for(int i=0;i<100;i++)
// 		sum(total,i);
// }

#include <complex.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

typedef struct {
	float hue; 
	float sat;
} HSV_Color;

typedef struct {
	int x;
	int y
} Point;

// CONSTANTS

// Screen sizes
#define COLUMN_SIZE 80
#define ROW_SIZE 60

// Memory Constants
#define MMIO 0x11000000
#define KEYBOARD 0x100
#define vG_ADDR 0x11000120
#define VG_COLOR 0x11000140

// For plotting

void draw_dot(Point p, HSV_Color color);
void draw_square(Point p1, Point p2);
void draw_axes();

// For function... ing?
complex execute_complex_function(Point p, char function[]);
int isOperation(char c);

// String manipulations
char* clean_str(char unclean_func);

// Begin MAIN!

void main() {

	int row,column = 0;

	complex i = 4.1f + 2.3f * I;

	__asm__("
		addi t1, x0, 0 
	");
	
}

// END MAIN

// Should fill a square with black between (x_1,y_1) and (x_2,y_2)
void draw_square(Point p1, Point p2) {

}

// Draw the color at position (x,y) with HSV color
void draw_dot(Point p, HSV_Color color) {
	// __asm__();
}

void draw_axes() {

}

// The parameter string function contains a prefix notation string. 
complex execute_complex_function(Point p, char function[]) {

	// From here we assume that the function is in prefix notation (ex: + 3 4 - 7 + 14 - ...)
	// Note that strlen uses the fact that \0 is the terminating character on a string. Ex: "Computer" has len = 9
	int length = strlen(function);

	if(length < 3) {

	}

	float i1 = function[0]

	for(int i = 0; i < strlen(function); i++) {
		
	}
}


int isOperation(char c) {
	switch (c)
	{
	case '+': // complex addition
		return 1;
		break;
	case '-': // complex subtraction
		return 1;
		break;
	case '*': // complex multiplication
		return 1;
		break;
	case '/': // complex division
		return 1;
		break;
	case '|': // complex magnitude (|z|)
		return 1;
		break;
	case 'arg': // complex argument (angle of z)
		return 1;
		break;
	default:
		return 0;
		break;
	}
}

// Take in a prefix string like:
// 2 3 + 6 e^ 4i ... and output it without spaces. 
char* clean_str(char unclean_func) {

}

