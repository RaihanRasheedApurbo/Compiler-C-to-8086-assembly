%option noyywrap
%x STATE0
%x STATE1
%x STATE2
%x MCOMMENT0
%x MCOMMENT1
%x MCOMMENT2
%x LCOMMENT0
%x LCOMMENT1
%x LCOMMENT2

%{
#include<cstdio>
#include<stdio.h>
//#include<iostrem>
#include<cstdlib>
#include<string>
#include<vector>
#include "SymbolTable.h"
#include "y.tab.h"
using namespace std;

extern int lineCount;
extern int errorCount;
extern SymbolTable *st;
extern FILE *errorFile;
extern FILE *logFile;
extern YYSTYPE yylval;






string s = "";
string comment ="";
int commentLine;


bool v = true; // v was not declared in this scope because of commenting
//out some codes.... so it has to change but now i am keeping it while
// testing how byson and flex works




%}




WHITESPACE [ \t\f\r\v]+
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE \n
UNDERSCORE _
IC '
METACHAR [\n\t\a\f\r\b\v\0]
KEY .
FLOAT ({DIGIT}*\.{DIGIT}+)(E[-+]?[0-9]+)?|{DIGIT}+(E[-+]?[0-9]+)
ID [a-zA-Z_][a-zA-Z0-9_]*
%%

{WHITESPACE} {

}


"/*" {
    //printf("entering mcomment0\n");
    comment = "";
    commentLine = lineCount;
    BEGIN MCOMMENT0;
}

<MCOMMENT0><<EOF>> {
    //fprintf(logout,"Line no %d: Unfinished comment error\n",commentLine);
    errorCount++;
    BEGIN INITIAL;

}

<MCOMMENT0>"*/" {
    //printf("multiline comment found: %s\n",comment.c_str());
    ////fprintf(tokenout,"<CONST_CHAR,%c%c>",s1,s2);
	//fprintf(logout,"Line no %d: multiline comment found: %s\n",commentLine,comment.c_str());
    BEGIN INITIAL;
}
<MCOMMENT0>\n {
    comment.append("\n");
    lineCount++;

}
<MCOMMENT0>. {
    
    
    comment.append(yytext);
}


"//" {
    //printf("starting lcomment0\n");
    comment = "";
    commentLine=lineCount;
    BEGIN LCOMMENT0;
}

<LCOMMENT0><<EOF>> {
    //printf("comment found:%s\n",comment.c_str());

	//fprintf(logout,"Line no %d: comment found: %s\n",commentLine,comment.c_str());
    BEGIN INITIAL;
}
<LCOMMENT0>\n {
    lineCount++;
    //fprintf(logout,"Line no %d: comment found: %s\n",commentLine,comment.c_str());
    BEGIN INITIAL;

}
<LCOMMENT0>"\\" {
    //printf("backslash found\n");
    //lineCount++;
    BEGIN LCOMMENT1;
}



<LCOMMENT1>. {
    char c = yytext[0];
    //printf("printing charecter %c\n",c);
    //printf("printing ascii of the charecter %d\n",c);
    //printf("printing ascii of newline %d\n",'\n');
    if(c==13)
    {
        //carriageFound = true;
        //BEGIN LCOMMENT0;
    }
    else
    {
        comment.append("\\");
        comment.append(yytext);
        //printf("%s\n",comment.c_str());
        BEGIN LCOMMENT0;

    }
    
}

<LCOMMENT1>[\n] {
    
    //printf("comment found: %s\n",comment.c_str());
    lineCount++;
    BEGIN LCOMMENT0;
}



<LCOMMENT0>. {
    comment.append(yytext);
    //printf("kill me");

}
















["]	{
	s = "";
    commentLine=lineCount;
	//printf("starting the state0\n");
	BEGIN STATE0;
}

<STATE0>["] {
    //printf("in state0\n");
    //printf("here should be string %s\n",s.c_str());
    //fprintf(tokenout,"<STRING, %s>",s.c_str());
	//fprintf(logout,"Line no %d: TOKEN <STRING> Lexeme %s found\n",commentLine,s.c_str());
    
    BEGIN INITIAL;
    yylval.symbol = new SymbolInfo(s,"STRING");
    return STRING;
}

<STATE0>[\n] {
    
    lineCount++;
    //fprintf(logout,"Line no %d: Unfinished string error\n",commentLine);
    errorCount++;
    BEGIN INITIAL;

    
    
        
    
}

<STATE0>[\\] {
    //printf("backslash found\n");
    BEGIN STATE1;
}

<STATE1>\n {
    lineCount++;
    BEGIN STATE0;

}

<STATE1>. {
    char c = yytext[0];
    //printf("printing charecter %c\n",c);
    //printf("printing ascii of the charecter %d\n",c);
    //printf("printing ascii of newline %d\n",'\n');
    if(c=='n')
    {
        s.append("\n");
        BEGIN STATE0;
    }
    else if(c=='t')
    {
        s.append("\t");
        BEGIN STATE0;

    }
    else if(c==13)
    {
        
    }
    else if(c=='a')
    {
        s.append("\a");
        BEGIN STATE0;

    }
    else if(c=='f')
    {
        s.append("\f");
        BEGIN STATE0;

    }
    else if(c=='r')
    {
        s.append("\r");
        BEGIN STATE0;

    }
    else if(c=='\\')
    {
        s.append("\\");
        BEGIN STATE0;

    }
    else if(c=='b')
    {
        s.append("\b");
        BEGIN STATE0;

    }
    else if(c=='v')
    {
        s.append("\v");
        BEGIN STATE0;

    }
    else if(c=='\'')
    {
        s.append("'");
        BEGIN STATE0;

    }
    else if(c=='"')
    {
        s.append("\"");
        BEGIN STATE0;

    }

    else if(c=='0')
    {
        s.append("\0");
        BEGIN STATE0;

    }
    else
    {
        //fprintf(logout,"Line no %d: Unknown scape sequence error\n",commentLine);
        BEGIN INITIAL;
    }

}



<STATE0>([^"\\\n])* {
    //printf("in state0\n");
    s.append(yytext);
    //printf("%s\n",yytext);

}


{IC}[\\][\\ntafrbv0']{IC} {   
    //metacharecter literals starts here

	char s1 = yytext[1];
	char s2 = yytext[2];
	//fprintf(tokenout,"<CONST_CHAR,%c%c>",s1,s2);
	//fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %c%c found\n",lineCount,s1,s2);
	//insert in symbol table and print symbol table content(only non empty buckets)
	//SymbolInfo *si=new SymbolInfo(string(yytext),"CONST_INT");
	//st.insert(si);
    char* k = new char[3];
    k[0] = yytext[1];
    k[1] = yytext[2];
    k[2] = '\0';
    string type = "CONST_CHAR" ;
    string name(k);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
    return CONST_CHAR;
}








{NEWLINE} {
	lineCount++;
}

"if" {		
	//keyword starts from here
	////fprintf(tokenout,"<IF>");
	////fprintf(logout,"Line no %d: TOKEN <IF> Lexeme %s found\n",lineCount,yytext);
    string type = "keyword" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
	return IF;
    
}

"else" {
	////fprintf(tokenout,"<ELSE>");
	////fprintf(logout,"Line no %d: TOKEN <ELSE> Lexeme %s found\n",lineCount,yytext);
    string type = "keyword" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
	return ELSE;
}

"for"	{
			////fprintf(tokenout,"<FOR>");
			////fprintf(logout,"Line no %d: TOKEN <FOR> Lexeme %s found\n",lineCount,yytext);
    string type = "keyword" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
	return FOR;		
}
"while"	{
			////fprintf(tokenout,"<WHILE>");
			////fprintf(logout,"Line no %d: TOKEN <WHILE> Lexeme %s found\n",lineCount,yytext);
    string type = "keyword" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
	return WHILE;
		}

"do"	{
			////fprintf(tokenout,"<DO>");
			////fprintf(logout,"Line no %d: TOKEN <DO> Lexeme %s found\n",lineCount,yytext);
    string type = "keyword" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
	return DO;		
}

"break"	{
			////fprintf(tokenout,"<BREAK>");
			////fprintf(logout,"Line no %d: TOKEN <BREAK> Lexeme %s found\n",lineCount,yytext);
    string type = "keyword" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
	return BREAK;		
}

"int"	{
			////fprintf(tokenout,"<INT>");
			////fprintf(logout,"Line no %d: TOKEN <INT> Lexeme %s found\n",lineCount,yytext);
    string type = "keyword" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
	return INT;		
}

"char"	{
			////fprintf(tokenout,"<CHAR>");
			////fprintf(logout,"Line no %d: TOKEN <CHAR> Lexeme %s found\n",lineCount,yytext);
    string type = "keyword" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
	return CHAR;		
}

"float"	{
			////fprintf(tokenout,"<FLOAT>");
			//fprintf(logout,"Line no %d: TOKEN <FLOAT> Lexeme %s found\n",lineCount,yytext);
    string type = "keyword" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
	return FLOAT;
}

"double"	{
			//fprintf(tokenout,"<DOUBLE>");
			//fprintf(logout,"Line no %d: TOKEN <DOUBLE> Lexeme %s found\n",lineCount,yytext);
    string type = "keyword" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
	return DOUBLE;
}

"void"	{
			//fprintf(tokenout,"<VOID>");
			//fprintf(logout,"Line no %d: TOKEN <VOID> Lexeme %s found\n",lineCount,yytext);
    string type = "keyword" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
	return VOID;
}

"return"	{
			//fprintf(tokenout,"<RETURN>");
			//fprintf(logout,"Line no %d: TOKEN <RETURN> Lexeme %s found\n",lineCount,yytext);
    string type = "keyword" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
	return RETURN;
}

"switch"	{
			//fprintf(tokenout,"<SWITCH>");
			//fprintf(logout,"Line no %d: TOKEN <SWITCH> Lexeme %s found\n",lineCount,yytext);
    string type = "keyword" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
	return SWITCH;
}

"case"	{
			//fprintf(tokenout,"<CASE>");
			//fprintf(logout,"Line no %d: TOKEN <CASE> Lexeme %s found\n",lineCount,yytext);
    string type = "keyword" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
	return CASE;
}

"default"	{
			//fprintf(tokenout,"<DEFAULT>");
			//fprintf(logout,"Line no %d: TOKEN <DEFAULT> Lexeme %s found\n",lineCount,yytext);

    string type = "keyword" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
	return DEFAULT;
}

"continue"	{
			//fprintf(tokenout,"<CONTINUE>");
			//fprintf(logout,"Line no %d: TOKEN <CONTINUE> Lexeme %s found\n",lineCount,yytext);
    string type = "keyword" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
	return CONTINUE;
}

"println" {
    string type = "keyword" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
    return PRINTLN;
}


"+"|"-"	{	//keyword completes here
	//fprintf(tokenout,"<ADDOP,%s>",yytext);
	//fprintf(logout,"Line no %d: TOKEN <ADDOP> Lexeme %s found\n",lineCount,yytext);
    string type = "ADDOP" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
	return ADDOP;        
}

"*"|"/"|"%"	{
	//fprintf(tokenout,"<MULOP,%s>",yytext);
	//fprintf(logout,"Line no %d: TOKEN <MULOP> Lexeme %s found\n",lineCount,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	// There is a '|' in "+"'s rule, this means match execute the action for following rule
    string type = "MULOP" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t; 
	return MULOP;
}

"++" {
	//fprintf(tokenout,"<INCOP,%s>",yytext);
	//fprintf(logout,"Line no %d: TOKEN <INCOP> Lexeme %s found\n",lineCount,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	// There is a '|' in "+"'s rule, this means match execute the action for following rule
    string type = "INCOP" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
	return INCOP; 
}

"--" {
	//fprintf(tokenout,"<INCOP,%s>",yytext);
	//fprintf(logout,"Line no %d: TOKEN <INCOP> Lexeme %s found\n",lineCount,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	// There is a '|' in "+"'s rule, this means match execute the action for following rule
    string type = "INCOP" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
	return DECOP;
}


"<"|"<="|">"|">="|"=="|"!=" {
	//fprintf(tokenout,"<RELOP,%s>",yytext);
	//fprintf(logout,"Line no %d: TOKEN <RELOP> Lexeme %s found\n",lineCount,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	// There is a '|' in "+"'s rule, this means match execute the action for following rule
    string type = "RELOP" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
	return RELOP;
}

"="	{
	//fprintf(tokenout,"<ASSIGNOP,%s>",yytext);
	//fprintf(logout,"Line no %d: TOKEN <ASSIGNOP> Lexeme %s found\n",lineCount,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	// There is a '|' in "+"'s rule, this means match execute the action for following rule
    string type = "ASSIGNOP" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
    return ASSIGNOP;
}

"&&"|"||" {
	//fprintf(tokenout,"<LOGICOP,%s>",yytext);
	//fprintf(logout,"Line no %d: TOKEN <LOGICOP> Lexeme %s found\n",lineCount,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	// There is a '|' in "+"'s rule, this means match execute the action for following rule
    string type = "LOGICOP" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
    return LOGICOP;
}

"&"|"|"|"<<"|">>" {
	//fprintf(tokenout,"<BITOP,%s>",yytext);
	//fprintf(logout,"Line no %d: TOKEN <BITOP> Lexeme %s found\n",lineCount,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	// There is a '|' in "+"'s rule, this means match execute the action for following rule
    string type = "BITOP" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t; 
    return BITOP;
}

"!"	{
	//fprintf(tokenout,"<NOT,%s>",yytext);
	//fprintf(logout,"Line no %d: TOKEN <NOT> Lexeme %s found\n",lineCount,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	// There is a '|' in "+"'s rule, this means match execute the action for following rule
    string type = "NOT" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
    return NOT; 
}

"("	{
	//fprintf(tokenout,"<LPAREN,%s>",yytext);
	//fprintf(logout,"Line no %d: TOKEN <LPAREN> Lexeme %s found\n",lineCount,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	// There is a '|' in "+"'s rule, this means match execute the action for following rule
    string type = "LPAREN" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
    return LPAREN;  
}

")"	{
	//fprintf(tokenout,"<RPAREN,%s>",yytext);
	//fprintf(logout,"Line no %d: TOKEN <RPAREN> Lexeme %s found\n",lineCount,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	// There is a '|' in "+"'s rule, this means match execute the action for following rule
    string type = "RPAREN" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t; 
    return RPAREN;
}

"{" {
	//fprintf(tokenout,"<LCURL,%s>",yytext);
	//fprintf(logout,"Line no %d: TOKEN <LCURL> Lexeme %s found\n",lineCount,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	// There is a '|' in "+"'s rule, this means match execute the action for following rule
    string type = "LCURL" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
    return LCURL; 
}

"}"	{
	//fprintf(tokenout,"<RCURL,%s>",yytext);
	//fprintf(logout,"Line no %d: TOKEN <RCURL> Lexeme %s found\n",lineCount,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	// There is a '|' in "+"'s rule, this means match execute the action for following rule
    string type = "RCURL" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
    return RCURL;
}

"["	{
	//fprintf(tokenout,"<LTHIRD,%s>",yytext);
	//fprintf(logout,"Line no %d: TOKEN <LTHIRD> Lexeme %s found\n",lineCount,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	// There is a '|' in "+"'s rule, this means match execute the action for following rule
    string type = "LTHIRD" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
    return LTHIRD; 
}

"]"	{
	//fprintf(tokenout,"<RTHIRD,%s>",yytext);
	//fprintf(logout,"Line no %d: TOKEN <RTHIRD> Lexeme %s found\n",lineCount,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	// There is a '|' in "+"'s rule, this means match execute the action for following rule
    string type = "RTHIRD" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
    return RTHIRD; 
}

","	{
	//fprintf(tokenout,"<COMMA,%s>",yytext);
	//fprintf(logout,"Line no %d: TOKEN <COMMA> Lexeme %s found\n",lineCount,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	// There is a '|' in "+"'s rule, this means match execute the action for following rule
    string type = "COMMA" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t; 
    return COMMA;
}

";"	{
	//fprintf(tokenout,"<SEMICOLON,%s>",yytext);
	//fprintf(logout,"Line no %d: TOKEN <SEMICOLON> Lexeme %s found\n",lineCount,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	// There is a '|' in "+"'s rule, this means match execute the action for following rule
    string type = "SEMICOLON" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t; 
    return SEMICOLON; 
}




[a-zA-Z_][a-zA-Z0-9_]*  {

    //identifier code
    //fprintf(tokenout,"<ID,%s>",yytext);
    //fprintf(logout,"Line no %d: TOKEN <ID> Lexeme %s found\n",lineCount,yytext);
    //symboltable code

    string type = "ID" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
    return ID;


}

{IC}[\\]{IC}|{IC}([^'\r\n\t\f\v])* {
    //fprintf(logout,"Line no %d: Unfinished character error %s\n",lineCount,yytext);
    errorCount++;
}

{IC}.{IC} {   

	char s = yytext[1];
	//fprintf(tokenout,"<CONST_CHAR,%c>",s);
	//fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %c found\n",lineCount,s);
	//insert in symbol table and print symbol table content(only non empty buckets)
	//SymbolInfo *si=new SymbolInfo(string(yytext),"CONST_INT");
	//st.insert(si);
    char *k = new char[2];
    k[0]=yytext[1];
    k[1]='\0';
    string type = "CONST_CHAR" ;
    string name(k);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
    return CONST_CHAR;
}

















({DIGIT}*\.{DIGIT}+)(E[-+]?[0-9]+)?|{DIGIT}+(E[-+]?[0-9]+)  {
	//fprintf(tokenout,"<CONST_FLOAT,%s>",yytext);
	//fprintf(logout,"Line no %d: TOKEN <CONST_FLOAT> Lexeme %s found\n",lineCount,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	//SymbolInfo *si=new SymbolInfo(string(yytext),"CONST_INT");
	//st.insert(si);
    string type = "CONST_FLOAT" ;
    //string type = "CONST_INT" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
    return CONST_FLOAT;
}

({DIGIT}*\.{DIGIT}*\.).* {
    //fprintf(logout,"Line no %d: Too many decimal point error %s\n",lineCount,yytext);
    errorCount++;
}

({DIGIT}*\.{DIGIT}+)(E[-+]?{FLOAT})?|{DIGIT}+(E[-+]?{FLOAT}) {
    //fprintf(logout,"Line no %d: Ill formed number error %s\n",lineCount,yytext);
    errorCount++;
}

{DIGIT}+{ID} {
    //fprintf(logout,"Line no %d: Invalid Suffix on numeric constant or invalid prefix on identifier for character sequence %s\n",lineCount,yytext);
    errorCount++;
}

{IC}[^\\\n\r][^\n\r]+{IC} {
    //printf("1%s\n",yytext);
    /*int len = strlen(yytext);
    for(int i=0;i<len;i++)
    {
        printf("%c %d\n",yytext[i],yytext[i]);
    }*/

    //fprintf(logout,"Line no %d: Multi character constant error %s\n",lineCount,yytext);
    errorCount++;
}

{IC}[\\][^'\r\n\t\f\v][^'\r\n\t\f\v]+{IC} {
   // printf("2%s\n",yytext);

    //fprintf(logout,"Line no %d: Multi character constant error %s\n",lineCount,yytext);
    errorCount++;
}

{IC}[\\][^\\ntafrbv0']{IC} {
    //printf("3%s\n",yytext);

    //fprintf(logout,"Line no %d: Multi character constant error %s\n",lineCount,yytext);
    errorCount++;
}














{DIGIT}+ {  
	//fprintf(tokenout,"<CONST_INT,%s>",yytext);
	//fprintf(logout,"Line no %d: TOKEN <CONST_INT> Lexeme %s found\n",lineCount,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	//SymbolInfo *si=new SymbolInfo(string(yytext),"CONST_INT");
	//st.insert(si);
    //string type = "CONST_FLOAT" ;
    string type = "CONST_INT" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    yylval.symbol = t;
    return CONST_INT;
    
}

. {
    //fprintf(logout,"Line no %d: Unrecognized charecter %s\n",lineCount,yytext);
}

<<EOF>> {
    //fprintf(logout,"Total error %d\n",errorCount);
    //fprintf(logout,"Total line %d\n",lineCount);
    //st.printFile();
    return 0;
}







%%

/*int main(int argc,char *argv[]){

	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}

	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}

	logout= fopen("log.txt","w");
	tokenout= fopen("token.txt","w");

	yyin= fin;
	yylex();
	////st.print();
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}*/

