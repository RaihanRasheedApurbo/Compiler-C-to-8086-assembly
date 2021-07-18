%{
#include<cstdio>
#include<stdio.h>
//#include<iostrem>
#include<cstdlib>
#include<stdlib.h>
#include<string>
#include<vector>
#include<string.h>
#include "SymbolTable.h"
using namespace std;




int lineCount = 1;
int errorCount = 0;
int warningCount = 0;
int bucketLength = 10;
//string currentTypeSpecifier;
SymbolTable *st = new SymbolTable(bucketLength);
FILE *inputFile;
FILE *errorFile;
FILE *logFile;


vector<string>typeSpecifier;
vector<string>value;
vector<string> declarationID;
vector<int> declarationSize;
vector<string> argumentList;
SymbolInfo* currentFunctionPointer;


vector<string> functionVariableNames;
vector<string> variableNames;
vector<string> arrayVariableNames;
vector<string> arrayVariableSize;
vector<SymbolInfo*> argumentSymbols;


int labelCount = 0;
int tempCount = 0;
string currentFunctionName ="needed to be set";

char *newLabel()
{
	char *lb= new char[4];
	strcpy(lb,"L");
	char b[3];
	sprintf(b,"%d", labelCount);
	labelCount++;
	strcat(lb,b);
	return lb;
}

char *newTemp()
{
	char *t= new char[4];
	strcpy(t,"t");
	char b[3];
	sprintf(b,"%d", tempCount);
	tempCount++;
	strcat(t,b);
	return t;
}


int removeWhiteSpace(char* &ptr)
{
    int flag = 1;
    while(true)
    {
        if(ptr==0)
        {
            flag = -1;
            break;
        }
        else if(*ptr == '\0')
        {
            flag = -1;
            break;
        }
        else if(*ptr == '\t' || *ptr == ' ' || *ptr == ',')
        {
            ptr++;
            continue;
        }
        else
        {
            break;
        }
        
    }
    return flag;
    
}
char* extractID(char* &ptr)
{
    char *ret = new char[100];
    char *ret1 = ret;
    while(true)
    {
        if(ptr==0)
        {
            *ret1 = '\0';
            return ret;
        }
        else if(*ptr ==' '|| *ptr == '\t' || *ptr == ','|| *ptr =='\0' || *ptr == '\n')
        {
            *ret1 = '\0';
            ptr++;
            return ret;
        }
        else
        {
            *ret1 = *ptr;
        }
        ret1++;
        ptr++;
    }
}

void optimizeAssemblyCode(vector<string> &lines)
{
    // printf("%d\n",lines.size());
    // string line = lines[0];
    for(int i=0;i<lines.size();i++)
    {
        char *src = new char[100];
        char *src1 = new char[100];
        char *destination = new char[100];
        char *destination1 = new char[100];
        string line = lines[i];
        char *ptr = new char[100];
        for(int i=0;i<line.size();i++)
        {
            ptr[i]=line[i];

        }
        ptr[line.size()]= '\0';
        //printf("%s",ptr);
        int flag = removeWhiteSpace(ptr);
        int flag1 = 1;
        //printf("%s",ptr);
        if(flag>0)
        {
            if(strlen(ptr)>=3)
            {
                char *temp = new char[4];
                for(int i=0;i<3;i++)
                {
                    temp[i]=ptr[i];
                }
                temp[3] = '\0';
                if(strcmp(temp,"MOV")==0)
                {
                    ptr = ptr + 3;
                    flag = removeWhiteSpace(ptr);
                    if(flag>0)
                    {
                        //printf("%s",ptr);
                        src = extractID(ptr);
                        //printf("%s\n%s",src,ptr);
                        flag = removeWhiteSpace(ptr);
                        //printf("%s\n",ptr);
                        if(flag>0)
                        {

                            destination = extractID(ptr);
                            //printf("%s\n%s",destination,ptr);
                        }
                    }
                    
                    
                }
                else
                {
                    flag = -1;
                }
            }
            else
            {
                flag = -1;
            }

        }

        if(flag>0)
        {
            //printf("inside second if\n");
            string line1 = lines[i+1];

            ptr = new char[100];
            for(int i=0;i<line1.size();i++)
            {
                ptr[i]=line1[i];

            }
            ptr[line1.size()]= '\0';
            //printf("%s",ptr);
            flag1 = removeWhiteSpace(ptr);
            //printf("%s",ptr);
            if(flag1>0)
            {
                if(strlen(ptr)>=3)
                {
                    char *temp1 = new char[4];
                    for(int i=0;i<3;i++)
                    {
                        temp1[i]=ptr[i];
                    }
                    temp1[3] = '\0';
                    if(strcmp(temp1,"MOV")==0)
                    {
                        ptr = ptr + 3;
                        flag1 = removeWhiteSpace(ptr);
                        if(flag1>0)
                        {
                            //printf("%s",ptr);
                            src1 = extractID(ptr);
                            //printf("%s\n%s",src1,ptr);
                            flag1 = removeWhiteSpace(ptr);
                            //printf("%s\n",ptr);
                            if(flag1>0)
                            {

                                destination1 = extractID(ptr);
                                //printf("%s\n%s",destination1,ptr);
                            }
                        }
                    
                    
                    }
                    else
                    {
                        flag1 = -1;
                    }
                }
                else
                {
                    flag1 = -1;
                }

            }
        }


        if(flag>0&&flag1>0)
        {
            if(strcmp(src,destination1)==0&&strcmp(src1,destination)==0)
            {
                //printf("matched like hell%d\n",i);
                //printf("%s\n",src);
                //printf("%s\n",destination1);
                //printf("%s\n",src1);
                //printf("%s\n",destination);
                //printf("previous size %d\n",lines.size());
                lines.erase(lines.begin()+i+1);
                //printf("after size %d\n",lines.size());
                i = i-1;

            }
        }
                
        
        
    }
    
}



extern FILE *yyin;

int yylex();
void yyerror(const char *s)
{
    printf("error occured at %d: %s\n\n",lineCount,s);
}

%}

%token IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE
%token VOID RETURN SWITCH CASE DEFAULT CONTINUE PRINTLN
%token ADDOP MULOP INCOP DECOP RELOP ASSIGNOP LOGICOP BITOP NOT
%token LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON
%token ID CONST_CHAR CONST_FLOAT CONST_INT STRING


%nonassoc NO_ELSE
%nonassoc ELSE


%right ASSIGNOP
%left LOGICOP
%left BITOP
%left RELOP 
%left ADDOP 
%left MULOP
%right INCOP DECOP NOT



%error-verbose



%union {
    SymbolInfo* symbol;
}


%type <s>start
%%




start : 
program {
    string front;
    front = front + ".MODEL SMALL\n\.STACK 100h\n\.DATA\n";

    for(int i=0;i<arrayVariableNames.size();i++)
    {
        front = front + arrayVariableNames[i] + " dw " + arrayVariableSize[i] + " dup(?) \n" ;
    }


    for(int i=0;i<variableNames.size();i++)
    {
        front = front + variableNames[i] + " dw ? \n" ; 
    }
    front = front + ".CODE\n";
    $<symbol>1->code = front + $<symbol>1->code;


    //***********************
    // println assemblyCode should be placed here
    $<symbol>1->code += "PRINTDC PROC  \n\ 
    PUSH AX \n\ 
    PUSH BX \n\ 
    PUSH CX \n\ 
    PUSH DX  \n\ 
    CMP AX,0 \n\ 
    JGE BEGIN \n\ 
    PUSH AX \n\ 
    MOV DL,'-' \n\ 
    MOV AH,2 \n\ 
    INT 21H \n\ 
    POP AX \n\ 
    NEG AX \n\ 
    \n\ 
    BEGIN: \n\ 
    XOR CX,CX \n\ 
    MOV BX,10 \n\ 
    \n\ 
    REPEAT: \n\ 
    XOR DX,DX \n\ 
    DIV BX \n\ 
    PUSH DX \n\ 
    INC CX \n\ 
    OR AX,AX \n\ 
    JNE REPEAT \n\ 
    MOV AH,2 \n\ 
    \n\ 
    PRINT_LOOP: \n\ 
    POP DX \n\ 
    ADD DL,30H \n\ 
    INT 21H \n\ 
    LOOP PRINT_LOOP \n\ 
    \n\    
    MOV AH,2\n\
    MOV DL,10\n\
    INT 21H\n\
    \n\
    MOV DL,13\n\
    INT 21H\n\
	\n\
    POP DX \n\ 
    POP CX \n\ 
    POP BX \n\ 
    POP AX \n\ 
    ret \n\ 
PRINTDC ENDP \n\
END MAIN\n";

    FILE* assemblyCode = fopen("code.asm","w");
    fprintf(assemblyCode,"%s\n",$<symbol>1->code.c_str());
    fclose(assemblyCode);


    assemblyCode = fopen("code.asm","r");
    char *line = new char[100];
    vector<string> lines;
    while(fgets(line,40,assemblyCode)!=0)
    {
        //printf("hi1 %s\n",line);
        lines.push_back(line);
    }
    optimizeAssemblyCode(lines);

    FILE *optimizedCode = fopen("optimizedCode.asm","w");
    string opCode = "";
    for(int i=0;i<lines.size();i++)
    {
        opCode = opCode + lines[i];
    }
    fprintf(optimizedCode,"%s\n",opCode.c_str());
    fclose(optimizedCode);

    


}

program : 
program unit {
    string type = "program" ;
    string symbol = $<symbol>1->getSymbol()+$<symbol>2->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  program : program unit\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());
    //$<symbol>$->code.append("hey");
    // ab = 
    //printf("%s\n",$<symbol>$->code.c_str());



    $<symbol>$->code = $<symbol>1->code + $<symbol>2->code;

    

}
| unit {
    string type = "program" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  program : unit\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());




    $<symbol>$->code = $<symbol>1->code ;

}

unit :
var_declaration {
    string type = "unit" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  unit : var_declaration\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    
    $<symbol>$->code = $<symbol>1->code ;
    functionVariableNames.clear();


}
| func_declaration {
    string type = "unit" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  unit : func_declaration\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());



    $<symbol>$->code = $<symbol>1->code ;

}
| func_definition {
    string type = "unit" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  unit : func_definition\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());



    $<symbol>$->code = $<symbol>1->code ;

}
					
func_declaration :
type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
    string type = "func_declaration" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+" "+$<symbol>4->getSymbol()+" "+$<symbol>5->getSymbol()+" "+$<symbol>6->getSymbol()+"\n";
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());
    


    SymbolInfo* found = st->lookUpCurrent($<symbol>2->getSymbol());
    //printf("value of found %d at line %d\n\n",found,lineCount);
    if(found==0)
    {
        found = new SymbolInfo($<symbol>2->getSymbol(),"function");
        found->e = new Extra;
        found->e->is_function = true;
        found->e->is_defined = false;
        found->e->returnType = $<symbol>1->getSymbol();
        bool voidFound = false;
        for(int i=0;i<typeSpecifier.size();i++)
        {
            if(typeSpecifier[i].compare("void")==0)
            {
                errorCount++;
                fprintf(logFile,"ERROR at line no %d :for parameter number %d void can't be parameter datatype\n\n",lineCount,i+1);
                fprintf(errorFile,"ERROR at line no %d : for parameter number %d void can't be parameter datatype\n\n",lineCount,i+1);
                voidFound = true;
                break;
            }
            found->typeSpecifier.push_back(typeSpecifier[i]);
            found->value.push_back(value[i]);
        }
        if(!voidFound)
        {
            st->insertion(found);
        
        }
        //printf("typeSpecifier size %d \n",typeSpecifier.size());
        typeSpecifier.clear();
        value.clear();
        
        //printf("typeSpecifier size %d \n",typeSpecifier.size());
    }
    else 
    {
        if(found->e==0)
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);

        }
        else if(found->e->is_function == false) 
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);

        }
        else if(found->e->returnType.compare($<symbol>1->getSymbol()) != 0 )
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : return type does not match with previously declared signature\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : return type does not match with previously declared signature\n\n",lineCount);
        
        }
        else if(found->typeSpecifier.size()!=typeSpecifier.size())
        {
            errorCount++;
           //printf("%d %d\n\n",found->typeSpecifier.size(),typeSpecifier.size());
            fprintf(logFile,"ERROR at line no %d : parameter list size does not match with previously declared signature\n\n",lineCount);
            //printf("check\n");
            fprintf(errorFile,"ERROR at line no %d : parameter list size does not match with previously declared signature\n\n",lineCount);
            
        }      
        else if(found->typeSpecifier.size()==typeSpecifier.size())
        {
                    
            for(int i=0;i<typeSpecifier.size();i++)
            {
                if(found->typeSpecifier[i].compare(typeSpecifier[i]) != 0)
                {
                    errorCount++;
                    fprintf(logFile,"ERROR at line no %d : signature does not match with previously declared signature\n\n",lineCount);
                    fprintf(errorFile,"ERROR at line no %d : signature does not match with previously declared signature\n\n",lineCount);
                    
                    break;
                }
            }

            
        }

        //printf("typeSpecifier size %d \n",typeSpecifier.size());
        typeSpecifier.clear();
        value.clear();

                
    }
    
    
    
}
| type_specifier ID LPAREN RPAREN SEMICOLON {
    string type = "func_declaration" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+" "+$<symbol>4->getSymbol()+" "+$<symbol>5->getSymbol()+"\n";
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());



    SymbolInfo* found = st->lookUpCurrent($<symbol>2->getSymbol());
    //printf("value of found %d at line %d\n\n",found,lineCount);
    if(found==0)
    {
        found = new SymbolInfo($<symbol>2->getSymbol(),"function");
        found->e = new Extra;
        found->e->is_function = true;
        found->e->is_defined = false;
        found->e->returnType = $<symbol>1->getSymbol();
        st->insertion(found);
        
        
    }
    else 
    {
        if(found->e==0)
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);

        }
        else if(found->e->is_function == false) 
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);

        }
        else if(found->e->returnType.compare($<symbol>1->getSymbol()) != 0 )
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : return type does not match with previously declared signature\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : return type does not match with previously declared signature\n\n",lineCount);

        }
        else if(found->typeSpecifier.size()!=typeSpecifier.size())
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : parameter list size does not match with previously declared signature\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : parameter list size does not match with previously declared signature\n\n",lineCount);

        }      
        else if(found->typeSpecifier.size()==typeSpecifier.size())
        {
            
                    
            for(int i=0;i<typeSpecifier.size();i++)
            {
                if(found->typeSpecifier[i].compare(typeSpecifier[i]) != 0)
                {
                    errorCount++;
                    fprintf(logFile,"ERROR at line no %d : signature does not match with previously declared signature\n\n",lineCount);
                    fprintf(errorFile,"ERROR at line no %d : signature does not match with previously declared signature\n\n",lineCount);
                  
                    break;
                }
            }
        }

                
    }
}

func_definition : 
type_specifier ID LPAREN parameter_list RPAREN {

//printf("kill me\n");
    //printf("%s %s\n",$<symbol>1->getSymbol().c_str(),$<symbol>2->getSymbol().c_str());
    
    currentFunctionName = $<symbol>2->getSymbol();
          
    string type = "func_definition" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+" "+$<symbol>4->getSymbol()+" "+$<symbol>5->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());
    /*for(int i=0;i<typeSpecifier.size();i++)
    {
        fprintf(logFile,"%s\n\n",typeSpecifier[i].c_str());
        fprintf(logFile,"%s\n\n",value[i].c_str());
        
    }*/
    SymbolInfo* found = st->lookUp($<symbol>2->getSymbol());
    //printf("value of found %d at line %d\n\n",found,lineCount);
    
    //printf("%d\n",found);
    //st->printFile(errorFile);




    bool createAssemblyCode = false;
    
    if(found==0)
    {
        found = new SymbolInfo($<symbol>2->getSymbol(),"function");
        found->e = new Extra;
        found->e->is_function = true;
        found->e->is_defined = true;
        found->e->returnType = $<symbol>1->getSymbol();

        //printf("in function definition cfg typeSpecifier size %d \n",typeSpecifier.size());
        bool voidFound = false;
        string scopeID = to_string(st->getNextScopeNumber());
        for(int i=0;i<typeSpecifier.size();i++)
        {
            if(typeSpecifier[i].compare("void")==0)
            {
                errorCount++;
                fprintf(logFile,"ERROR at line no %d :for parameter number %d void can't be parameter datatype\n\n",lineCount,i+1);
                fprintf(errorFile,"ERROR at line no %d : for parameter number %d void can't be parameter datatype\n\n",lineCount,i+1);
                voidFound = true;
                break;
            }
            found->typeSpecifier.push_back(typeSpecifier[i]);
            found->value.push_back(value[i]);
            string asdf = value[i] + scopeID;
            found->assemblyParameterName.push_back(value[i]+scopeID);

        }
        //printf("in function definition cfg %d %d\n",found->typeSpecifier.size(),typeSpecifier.size());
        if(!voidFound)
        {
            st->insertion(found);
            createAssemblyCode = true;
            currentFunctionPointer = found;
        
        }
        //typeSpecifier.clear();
        //value.clear();
        
    }
    else 
    {
        //printf("killme\n");
        //printf("%s %s %s\n",found->e->returnType.c_str(),$<symbol>1->getSymbol().c_str(),$<symbol>2->getSymbol().c_str());
            
        if(found->e==0)
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);
    
        }
        else if(found->e->is_function == false) 
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);

        }
        else if(found->e->is_defined == true) 
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : multiple definition exists for same function name\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : multiple definition exists for same function name\n\n",lineCount);

        }
        else if(found->e->returnType.compare($<symbol>1->getSymbol()) != 0 )
        {
            //printf("%s %s\n",found->e->returnType.c_str(),$<symbol>1->getSymbol().c_str());
            
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : return type does not match with previously declared signature\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : return type does not match with previously declared signature\n\n",lineCount);

        }
        else if(found->typeSpecifier.size()!=typeSpecifier.size())
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : parameter list size does not match with previously declared signature\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : parameter list size does not match with previously declared signature\n\n",lineCount);

        }      
        else if(found->typeSpecifier.size()==typeSpecifier.size())
        {
                    
            for(int i=0;i<typeSpecifier.size();i++)
            {
                if(found->typeSpecifier[i].compare(typeSpecifier[i]) != 0)
                {
                    errorCount++;
                    fprintf(logFile,"ERROR at line no %d : signature and function definition does not have same parameter type\n\n",lineCount);
                    fprintf(errorFile,"ERROR at line no %d : signature and function definition does not have same parameter type\n\n",lineCount);
                    
                    break;
                }
            }
            found->e->is_defined = true;
            createAssemblyCode = true;

            
        }
        
        

                
    }

} compound_statement{
    
    
    if(true)
    {
       // type_specifier ID LPAREN parameter_list RPAREN compound_statement{
    //printf("kill me\n");
        
        string assemblyCode;
        assemblyCode = assemblyCode + $<symbol>2->getSymbol() + " PROC\n" ;
        if($<symbol>2->getSymbol().compare("main")==0)
        {

            assemblyCode = assemblyCode + "MOV AX, @DATA\nMOV DS, AX\n" ;
            assemblyCode = assemblyCode + $<symbol>7->code ;
            assemblyCode = assemblyCode + "LReturn" + $<symbol>2->getSymbol() + ":\n" ;
            assemblyCode = assemblyCode + "\tMOV AH, 4CH\n\tINT 21H\n" ;
        }
        else
        {
            
            SymbolInfo* found = st->lookUp($<symbol>2->getSymbol());
            assemblyCode = assemblyCode + "\tPUSH AX\n\tPUSH BX \n\tPUSH CX \n\tPUSH DX\n" ;
            string scopeID = st->getCurrentScopeID();
            for(int i=0;i<found->assemblyFunctionTempVariableName.size();i++)
            {
                assemblyCode = assemblyCode + "\tPUSH "+ found->assemblyFunctionTempVariableName[i] + "\n";
            }
            for(int i=0;i<found->typeSpecifier.size();i++)
            {
                
                //found->assemblyParameterName.push_back(value[i]+scopeID); 
                assemblyCode = assemblyCode + "\tPUSH " + found->assemblyParameterName[i] + "\n" ;
            }
            for(int i=0;i<functionVariableNames.size();i++)
            {
                //found->assemblyFunctionVariableName.push_back(functionVariableNames[i]);
                assemblyCode = assemblyCode + "\tPUSH " + functionVariableNames[i] + "\n" ;

            }
            assemblyCode = assemblyCode + $<symbol>7->code;
            assemblyCode = assemblyCode + "LReturn" + $<symbol>2->getSymbol() + ":\n" ;
            for(int i=functionVariableNames.size()-1;i>=0;i--)
            {
                assemblyCode = assemblyCode + "\tPOP " + functionVariableNames[i] + "\n" ;

            }
            for(int i=found->typeSpecifier.size()-1;i>=0;i--)
            {
                assemblyCode = assemblyCode + "\tPOP " + found->assemblyParameterName[i] + "\n" ;
            }
            for(int i=found->assemblyFunctionTempVariableName.size()-1;i>=0;i--)
            {
                assemblyCode = assemblyCode + "\tPOP "+ found->assemblyFunctionTempVariableName[i] + "\n";
            }
            assemblyCode = assemblyCode + "\tPOP DX\n\tPOP CX \n\tPOP BX \n\tPOP AX\n\tret\n" ;
            assemblyCode = assemblyCode + $<symbol>2->getSymbol() + " ENDP\n" ;
            

        }
        $<symbol>$->code = assemblyCode;
        variableNames.push_back($<symbol>2->getSymbol()+"_return");
    }
    
    functionVariableNames.clear();
    typeSpecifier.clear();
    value.clear();
    
    
        
}
    


| type_specifier ID LPAREN RPAREN {
    string type = "func_definition" ;
    currentFunctionName = $<symbol>2->getSymbol();
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+" "+$<symbol>4->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  func_definition : type_specifier ID LPAREN RPAREN compound_statement\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());


    bool createAssemblyCode = false;


    SymbolInfo* found = st->lookUp($<symbol>2->getSymbol());
    //printf("value of found %d at line %d\n\n",found,lineCount);
    if(found==0)
    {
        found = new SymbolInfo($<symbol>2->getSymbol(),"function");
        found->e = new Extra;
        found->e->is_function = true;
        found->e->is_defined = true;
        found->e->returnType = $<symbol>1->getSymbol();
        st->insertion(found);
        currentFunctionPointer = found;
        createAssemblyCode = true;
        
        
    }
    else 
    {
        if(found->e==0)
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);

        }
        else if(found->e->is_function == false) 
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : variable function name conflict\n\n",lineCount);

        }
        else if(found->e->is_defined == true) 
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : multiple definition exists for same function name\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : multiple definition exists for same function name\n\n",lineCount);

        }
        else if(found->e->returnType.compare($<symbol>1->getSymbol()) != 0 )
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : return type does not match with previously declared signature\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : return type does not match with previously declared signature\n\n",lineCount);

        }
        else if(found->typeSpecifier.size()!=typeSpecifier.size())
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : parameter list size does not match with previously declared signature\n\n",lineCount);
            fprintf(errorFile,"ERROR at line no %d : parameter list size does not match with previously declared signature\n\n",lineCount);

        }      
        else if(found->typeSpecifier.size()==typeSpecifier.size())
        {
            createAssemblyCode = true;      
            for(int i=0;i<typeSpecifier.size();i++)
            {
                if(found->typeSpecifier[i].compare(typeSpecifier[i]) != 0)
                {
                    errorCount++;
                    fprintf(logFile,"ERROR at line no %d : signature and function definition does not have same parameter type\n\n",lineCount);
                    fprintf(errorFile,"ERROR at line no %d : signature and function definition does not have same parameter type\n\n",lineCount);
                    createAssemblyCode = false;
                    break;
                }
            }
            found->e->is_defined = true;
            
            
        }

                
    }
    

    
}
compound_statement {
    
    if(true)
    {
       // type_specifier ID LPAREN parameter_list RPAREN compound_statement{
    //printf("kill me\n");
        
        
        string assemblyCode;
        assemblyCode = assemblyCode + $<symbol>2->getSymbol() + " PROC\n" ;

        if($<symbol>2->getSymbol().compare("main")==0)
        {

            assemblyCode = assemblyCode + "MOV AX, @DATA\nMOV DS, AX\n" ;
            assemblyCode = assemblyCode + $<symbol>6->code ;
            assemblyCode = assemblyCode + "LReturn" + $<symbol>2->getSymbol() + ":\n" ;
            assemblyCode = assemblyCode + "\tMOV AH, 4CH\n\tINT 21H\n" ;
        }
        else
        {
            SymbolInfo* found = st->lookUp($<symbol>2->getSymbol());
            assemblyCode = assemblyCode + "\tPUSH AX\n\tPUSH BX \n\tPUSH CX \n\tPUSH DX\n" ;
            // for(int i=0;i<found->typeSpecifier.size();i++)
            // {
            //     assemblyCode = assemblyCode + "\tPUSH " + found->value[i] + "\n" ;
            // }
            for(int i=0;i<functionVariableNames.size();i++)
            {
                assemblyCode = assemblyCode + "\tPUSH " + functionVariableNames[i] + "\n" ;

            }
            assemblyCode = assemblyCode + $<symbol>6->code;
            assemblyCode = assemblyCode + "LReturn" + $<symbol>2->getSymbol() + ":\n" ;
            for(int i=functionVariableNames.size()-1;i>=0;i--)
            {
                assemblyCode = assemblyCode + "\tPOP " + functionVariableNames[i] + "\n" ;

            }
            // for(int i=found->typeSpecifier.size()-1;i>=0;i--)
            // {
            //     assemblyCode = assemblyCode + "\tPOP " + found->value[i] + "\n" ;
            // }
         
            assemblyCode = assemblyCode + "\tPOP DX\n\tPOP CX \n\tPOP BX \n\tPOP AX\n\tret\n" ;
            assemblyCode = assemblyCode + $<symbol>2->getSymbol() + " ENDP\n" ;
            

        }
        functionVariableNames.clear();
        

        $<symbol>$->code = assemblyCode;
        variableNames.push_back($<symbol>2->getSymbol()+"_return");
    }
    typeSpecifier.clear();
    value.clear();
    
}

parameter_list : 
parameter_list COMMA type_specifier ID {
    string type = "parameter_list" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+" "+$<symbol>4->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    typeSpecifier.push_back($<symbol>3->getSymbol());
    value.push_back($<symbol>4->getSymbol());
    //printf("%s %s\n",$<symbol>3->getSymbol().c_str(),$<symbol>4->getSymbol().c_str());
    //printf("typeSpecifier size %d \n",typeSpecifier.size());
    fprintf(logFile,"At line no : %d  parameter_list : parameter_list COMMA type_specifier ID\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

}
| parameter_list COMMA type_specifier {
    string type = "parameter_list" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    typeSpecifier.push_back($<symbol>3->getSymbol());
    value.push_back("");
    //printf("%s %s\n",$<symbol>3->getSymbol().c_str(),$<symbol>2->getSymbol().c_str());
    
    fprintf(logFile,"At line no : %d  parameter_list : parameter_list COMMA type_specifier\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

}
| type_specifier ID{
    string type = "parameter_list" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol();
    typeSpecifier.push_back($<symbol>1->getSymbol());
    value.push_back($<symbol>2->getSymbol());
    //printf("%s %s\n",$<symbol>1->getSymbol().c_str(),$<symbol>2->getSymbol().c_str());
    
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  parameter_list : type_specifier ID\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

}
| type_specifier {
    
    string type = "parameter_list" ;
    string symbol = $<symbol>1->getSymbol();
    typeSpecifier.push_back($<symbol>1->getSymbol());
    value.push_back("");
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  parameter_list : type_specifier\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());
    //printf("%s \n",$<symbol>1->getSymbol().c_str());
    

}

compound_statement : LCURL
{
    //printf("hello world");
    //printf("hello world from LCURL\n\n");
    st->enterScope();
    string scopeID = st->getCurrentScopeID();
    //printf("new scope opened\n");
    for(int i=0;i<typeSpecifier.size();i++)
    {
        
        variableNames.push_back(value[i]+scopeID);
        string symbol = value[i];
        SymbolInfo* found = st->lookUpCurrent(symbol);
        if(found!=0)
        {
            errorCount++;
            //printf("error for %s\n",symbol.c_str());
            //printf("error found %d\n",lineCount);
            fprintf(logFile,"ERROR at line no %d : %s name already exists\n\n",lineCount-2,symbol.c_str());
            fprintf(errorFile,"ERROR at line no %d : %s name already exists\n\n",lineCount-2,symbol.c_str());
            
            continue;
        }
        
        //int size1 = declarationSize[i];
        string type = typeSpecifier[i];
        SymbolInfo* send = new SymbolInfo(symbol,type);
        send->e = new Extra;
        send->e->returnType = type;
        //printf("%s\n",send->e->returnType.c_str());
        st->insertion(send);
        

    }
    //typeSpecifier.clear();
    //value.clear();

} statements RCURL
{
    
    //printf("entering into new scope\n\n");
    string type = "compound_statement" ;
    string symbol = $<symbol>1->getSymbol()+"\n"+$<symbol>3->getSymbol()+"\n"+$<symbol>4->getSymbol()+"\n";
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  compound_statement : LCURL statements RCURL\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());
    
    //printf("%s\n\n",$<symbol>3->getSymbol().c_str());
    /*for(int i=0;i<declarationID.size();i++)
    {
        //printf("identifier %s size %d\n\n",declarationID[i].c_str(),declarationSize[i]);
    }*/

    

    st->printFile(logFile);
    st->exitScope();
    //printf("scope exited\n");



    $<symbol>$->code = $<symbol>3->code;
    //printf("in compound_statement statments \n%s",$<symbol>$->code.c_str());
}

| LCURL 
{
    st->enterScope();
    //printf("new scope opened\n");
    for(int i=0;i<typeSpecifier.size();i++)
    {
        string symbol = value[i];
        SymbolInfo* found = st->lookUpCurrent(symbol);
        if(found!=0)
        {
            errorCount++;
            //printf("error for %s\n",symbol.c_str());
            //printf("error found %d\n",lineCount);    
            fprintf(logFile,"ERROR at line no %d : %s name already exists\n\n",lineCount-2,symbol.c_str());
            fprintf(errorFile,"ERROR at line no %d : %s name already exists\n\n",lineCount-2,symbol.c_str());
            
            continue;
        }
        //int size1 = declarationSize[i];
        string type = typeSpecifier[i];
        SymbolInfo* send = new SymbolInfo(symbol,type);
        send->e = new Extra;
        send->e->returnType = type;
        //printf("%s\n",send->e->returnType.c_str());
        st->insertion(send);
        

    }
    //typeSpecifier.clear();
    //value.clear();
} RCURL 
{
    string type = "compound_statement" ;
    string symbol = $<symbol>1->getSymbol()+"\n\n"+$<symbol>3->getSymbol()+"\n";
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  compound_statement : LCURL RCURL\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());
    st->exitScope();

}

var_declaration :
type_specifier declaration_list SEMICOLON {

    string type = "var_declaration" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+"\n";
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  var_declaration : type_specifier declaration_list SEMICOLON\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());
    //printf("%d",declarationID.size());
    if($<symbol>1->getSymbol().compare("void")==0)
    {
        errorCount++;
        fprintf(logFile,"ERROR at line no %d : can not declare varaible of void type\n\n",lineCount,symbol.c_str());
        fprintf(errorFile,"ERROR at line no %d : can not declare varaible of void type\n\n",lineCount,symbol.c_str());
            
    }


    for(int i=0;i<declarationID.size();i++)
    {
        string symbol = declarationID[i];
        string scopeID = st->getCurrentScopeID();
        SymbolInfo* found = st->lookUpCurrent(symbol);
        if(found!=0)
        {
            errorCount++;
            //printf("kill me 2 %s\n",symbol.c_str());    
            fprintf(logFile,"ERROR at line no %d : %s name already exists\n\n",lineCount,symbol.c_str());
            fprintf(errorFile,"ERROR at line no %d : %s name already exists\n\n",lineCount,symbol.c_str());
            
            continue;
        }
        int size1 = declarationSize[i];
        string type = $<symbol>1->getSymbol();
        SymbolInfo* send = new SymbolInfo(symbol,type);
        send->e = new Extra;
        send->e->returnType = type;
        //printf("kill me %s\n",symbol.c_str());
        //printf("%s\n",send->e->returnType.c_str());
        if(size1!=0)
        {
            //printf("kill me %s\n",symbol.c_str());
            send->e->is_array = true;
            //printf("%d %d\n",send->e->is_array,size1);
            send->e->arrayLength = size1;

            arrayVariableNames.push_back(symbol+scopeID);
            // char buffer[10];
            // itoa(size1,buffer,10);
            string num = to_string(size1);
            arrayVariableSize.push_back(num);
        }
        else
        {

            functionVariableNames.push_back(symbol+scopeID);
            variableNames.push_back(symbol+scopeID);
        }
        st->insertion(send);

        
        //functionVariableNames.push_back(symbol+scopeID);
        

    }
    declarationID.clear();
    declarationSize.clear();
    

}

type_specifier :
INT {
    string type = "type_specifier" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  type_specifier : INT\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());
}
| FLOAT {
    string type = "type_specifier" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  type_specifier : FLOAT\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());
}
| VOID {
    string type = "type_specifier" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  type_specifier : VOID\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

}

declaration_list :
declaration_list COMMA ID {
    string type = "declaration_list" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  declaration_list : declaration_list COMMA ID\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());
    string id = $<symbol>3->getSymbol();
    declarationID.push_back(id);
    int size1 = 0;
    //printf("printing size1 of %d\n",size1);
    declarationSize.push_back(size1);
    //printf("printing size again %d\n",declarationSize[declarationSize.size()-1]);

    /*for(int i=0;i<declarationSize.size();i++)
    {
        //printf("kill me %d\n",declarationSize[i]);
        //printf("kill me again %s\n",declarationID[i].c_str());
    }*/

    

}
| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
    string type = "declaration_list" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+" "+$<symbol>4->getSymbol()+" "+$<symbol>5->getSymbol()+" "+$<symbol>6->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());
    string id = $<symbol>3->getSymbol();
    //printf("kill me 3 %s\n",id.c_str());
    declarationID.push_back(id);
    int size1 = atoi($<symbol>5->getSymbol().c_str());
    //printf("%d\n",size1);
    declarationSize.push_back(size1);


}
| ID {
    string type = "declaration_list" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  declaration_list : ID\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    string id = $<symbol>1->getSymbol();
    declarationID.push_back(id);
    int size1 = 0;
    //printf("printing size1 of %d\n",size1);
    declarationSize.push_back(size1);
    //printf("printing size again %d\n",declarationSize[declarationSize.size()-1]);
    /*for(int i=0;i<declarationSize.size();i++)
    {
        //printf("kill me %d\n",declarationSize[i]);
        //printf("kill me again %s\n",declarationID[i].c_str());
    }*/

}
| ID LTHIRD CONST_INT RTHIRD {
    string type = "declaration_list" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+" "+$<symbol>4->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  declaration_list : ID LTHIRD CONST_INT RTHIRD\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    string id = $<symbol>1->getSymbol();
    //printf("kill me 3 %s\n",id.c_str());
    declarationID.push_back(id);
    int size1 = atoi($<symbol>3->getSymbol().c_str());
    declarationSize.push_back(size1);



}

statements :
statement {
    string type = "statements" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  statements : statement\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());



    $<symbol>$->code = $<symbol>1->code ;

    //printf("in statement \n%s",$<symbol>1->code.c_str());

}
| statements statement {
    string type = "statements" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  statements : statements statement\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());




    $<symbol>$->code = $<symbol>1->code + $<symbol>2->code ;
    //printf("in statements statement \n %s",$<symbol>$->code.c_str());


}

statement :
var_declaration {
    string type = "statement" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  statement : var_declaration\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    
    $<symbol>$->code = $<symbol>1->code ;



}
| expression_statement {
    string type = "statement" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  statement : expression_statement\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());


    $<symbol>$->code = $<symbol>1->code ;

}
| compound_statement {
    string type = "statement" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  statement : compound_statement\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());



    $<symbol>$->code = $<symbol>1->code ;

}
| FOR LPAREN expression_statement expression_statement expression RPAREN statement {
    string type = "statement" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+" "+$<symbol>4->getSymbol()+" "+$<symbol>5->getSymbol()+" "+$<symbol>6->getSymbol()+" "+$<symbol>7->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());



    string assemblyCode;
    assemblyCode = assemblyCode + $<symbol>3->code;
    char *l1 = newLabel();
    char *l2 = newLabel();
    assemblyCode = assemblyCode + string(l1) + ":\n" ;
    assemblyCode = assemblyCode + $<symbol>4->code;
    assemblyCode = assemblyCode + "\tMOV AX, " + $<symbol>4->assemblyName +"\n";
    assemblyCode = assemblyCode + "\tCMP AX, 0 \n" ;
    assemblyCode = assemblyCode + "\tJE "+string(l2)+"\n";
    assemblyCode = assemblyCode + $<symbol>7->code;
    assemblyCode = assemblyCode + $<symbol>5->code;
    assemblyCode = assemblyCode + "\tJMP "+string(l1) + "\n" ;
    assemblyCode = assemblyCode + string(l2) + ":\n" ;


    $<symbol>$->code = assemblyCode ;
    //printf("in compound_statement for loop\n %s",assemblyCode.c_str());




}
| IF LPAREN expression RPAREN statement %prec NO_ELSE{
    
    string type = "statement" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+" "+$<symbol>4->getSymbol()+" "+$<symbol>5->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  statement : IF LPAREN expression RPAREN statement\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());



    string assemblyCode;
    assemblyCode = assemblyCode + $<symbol>3->code;
    //printf("elow\n%s\nelow",assemblyCode.c_str());
    char *l1 = newLabel();


    assemblyCode = assemblyCode + "\tMOV AX, " + $<symbol>3->assemblyName + "\n" ;
    assemblyCode = assemblyCode + "\tCMP AX, 0\n" ;
    assemblyCode = assemblyCode + "\tJE " + string(l1) + ":\n" ;
    assemblyCode = assemblyCode + $<symbol>5->code ;
    assemblyCode = assemblyCode + string(l1) + ":\n" ;

    //printf("In compound_statement if statement checking symbol5\n %s",$<symbol>5->code.c_str());
    $<symbol>$->code = assemblyCode;
    //printf("In compound_statement if statement\n %s",$<symbol>$->code.c_str());
    
    






}
| IF LPAREN expression RPAREN statement ELSE statement{
   
    
    
    
    string type = "statement" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+" "+$<symbol>4->getSymbol()+" "+$<symbol>5->getSymbol()+" "+$<symbol>6->getSymbol()+" "+$<symbol>7->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  statement : IF LPAREN expression RPAREN statement ELSE statement\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());




    char *l1 = newLabel();
    char *l2 = newLabel();

    string assemblyCode;
    assemblyCode = assemblyCode + $<symbol>3->code;
    assemblyCode = assemblyCode + "\tMOV AX, " + $<symbol>3->assemblyName + "\n";
    assemblyCode = assemblyCode + "\tCMP AX, 0\n";
    assemblyCode = assemblyCode + "\tJE " + string(l1) + "\n";
    assemblyCode = assemblyCode + $<symbol>5->code;
    assemblyCode = assemblyCode + "\tJMP " + string(l2) + ":\n";
    assemblyCode = assemblyCode + string(l1) + ":\n";
    assemblyCode = assemblyCode + $<symbol>7->code;
    assemblyCode = assemblyCode + string(l2) + ":\n";
    
    
    
    $<symbol>$->code = assemblyCode;
    
}
| WHILE LPAREN expression RPAREN statement {
    
   


    string type = "statement" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+" "+$<symbol>4->getSymbol()+" "+$<symbol>5->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  statement : WHILE LPAREN expression RPAREN statement\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());




    char* l1 = newLabel();
    char* l2 = newLabel();
    
    string assemblyCode;
    assemblyCode = string(l1) + ":\n";
    assemblyCode = assemblyCode + $<symbol>3->code ;
    assemblyCode = assemblyCode + "\tMOV AX, " + $<symbol>3->assemblyName + "\n";
    assemblyCode = assemblyCode + "\tCMP AX, 0\n";
    assemblyCode = assemblyCode + "\tJE " + string(l2) + "\n";
    assemblyCode = assemblyCode + $<symbol>5->code;
    assemblyCode = assemblyCode + "\tJMP " + string(l1) + "\n";
    assemblyCode = assemblyCode + string(l2) + ":\n";
    

    $<symbol>$->code = assemblyCode;

}
| PRINTLN LPAREN ID RPAREN SEMICOLON {
    
    string type = "statement" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+" "+$<symbol>4->getSymbol()+" "+$<symbol>5->getSymbol()+"\n";
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());


    // int a=54325;
    // char buffer[20];
    // itoa(a,buffer,10);
    string scopeID = to_string(st->lookUpScope($<symbol>3->getSymbol()));
    //printf("%d\n",st->lookUpScope($<symbol>3->getSymbol()));

    $<symbol>$->code = "\tMOV AX, " + $<symbol>3->getSymbol() + scopeID + "\n\tCALL PRINTDC\n";


    //println handled in lexxer 
    

}
| RETURN expression SEMICOLON {

   

    string type = "statement" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+"\n";
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  statement : RETURN expression SEMICOLON\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());


    string assemblyCode = $<symbol>2->code + "\tMOV AX, " + $<symbol>2->assemblyName + "\n";
    //printf("expression\n%s",assemblyCode.c_str());
    assemblyCode = assemblyCode + "\MOV " + currentFunctionName + "_return, AX\n";
    assemblyCode = assemblyCode + "\tJMP LReturn" + currentFunctionName + "\n";
    $<symbol>$->code = assemblyCode;
    //printf("in return expression semicolon\n%s",$<symbol>$->code.c_str());




}  

expression_statement :
SEMICOLON {
    string type = "expression_statement" ;
    string symbol = $<symbol>1->getSymbol()+"\n";
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  expression_statement : SEMICOLON\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());
}
| expression SEMICOLON {
    string type = "expression_statement" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+"\n";
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  expression_statement : expression SEMICOLON\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());


    $<symbol>$->code = $<symbol>1->code ;
    $<symbol>$->assemblyName = $<symbol>1->assemblyName;
}

variable : 
ID {
    

    string type = "variable" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    SymbolInfo* v = $<symbol>$;
    v->e = new Extra;
    fprintf(logFile,"At line no : %d  variable : ID\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    SymbolInfo* found = st->lookUp(symbol);
    if(found==0)
    {
        errorCount++;
        fprintf(logFile,"ERROR at line no %d : variable name %s is not declared \n\n",lineCount,symbol.c_str());
        fprintf(errorFile,"ERROR at line no %d : variable name %s is not declared \n\n",lineCount,symbol.c_str());
        
        v->e->returnType = "int"; // error so in order to keep the code running i had no other option
    }
    else
    {
        if(found->e->is_array==true)
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : variable name %s is an array so should be indexed properly\n\n",lineCount,symbol.c_str());
            fprintf(errorFile,"ERROR at line no %d : variable name %s is an array so should be indexed properly\n\n",lineCount,symbol.c_str());
        
        }
        else if(found->e->is_function==true)
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : function name can't be used as variable name\n\n",lineCount,symbol.c_str());
            fprintf(errorFile,"ERROR at line no %d : function name can't be used as variable name\n\n",lineCount,symbol.c_str());
        

        }
        v->e->returnType = found->e->returnType;
    }




    string scopeID = to_string(st->lookUpScope($<symbol>1->getSymbol()));
    
    $<symbol>$->assemblyName = $<symbol>$->getSymbol() +scopeID; 


}
| ID LTHIRD expression RTHIRD {
    




    string type = "variable" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+" "+$<symbol>4->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    SymbolInfo* v = $<symbol>$;
    v->e = new Extra;
    fprintf(logFile,"At line no : %d  variable : ID LTHIRD expression RTHIRD\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    SymbolInfo* exp = $<symbol>3;
    //printf("asdf %s\n",exp->e->returnType.c_str());
    if(exp->e->returnType.compare("float")==0||exp->e->returnType.compare("void")==0)
    {
        errorCount++;
        fprintf(logFile,"ERROR at line no %d : for id %s index number should be integer \n\n",lineCount,symbol.c_str());
        fprintf(errorFile,"ERROR at line no %d : for id %s index number should be integer \n\n",lineCount,symbol.c_str());
       
    }

    string symbol1 = $<symbol>1->getSymbol();
    SymbolInfo* found = st->lookUp(symbol1);
    if(found==0)
    {
        errorCount++;
        fprintf(logFile,"ERROR at line no %d : variable name %s is not declared \n\n",lineCount,symbol.c_str());
        fprintf(errorFile,"ERROR at line no %d : variable name %s is not declared \n\n",lineCount,symbol.c_str());
        
        v->e->returnType = "int"; // error so in order to keep the code running i had no other option
    }
    else
    {
        
        if(found->e->is_array==false)
        {
            //printf("%d\n",v->e->is_array);
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : variable name %s is not an array \n\n",lineCount,symbol.c_str());
            fprintf(errorFile,"ERROR at line no %d : variable name %s is not an array \n\n",lineCount,symbol.c_str());
         
        }
        else if(found->e->is_function==true)
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : function name can't be used as variable name\n\n",lineCount,symbol.c_str());
            fprintf(errorFile,"ERROR at line no %d : function name can't be used as variable name\n\n",lineCount,symbol.c_str());
        

        }
        v->e->returnType = found->e->returnType;
        //printf("3. %s\n",found->e->returnType.c_str());
        //fprintf(logFile,"kill me\n\n");
        
        //st->printFile(logFile);
    }


    string assemblyCode;
    string scopeID = to_string(st->lookUpScope($<symbol>1->getSymbol()));
    
    assemblyCode = assemblyCode + $<symbol>3->code ;
    assemblyCode = assemblyCode + "\tMOV BX, " + $<symbol>3->assemblyName + "\n";
    assemblyCode = assemblyCode + "\tADD BX, BX\n";
    $<symbol>$->assemblyName = $<symbol>1->getSymbol() + scopeID ;
    $<symbol>$->code = assemblyCode;
    $<symbol>$->e->is_array = true;
    $<symbol>$->indexNumber = $<symbol>3->assemblyName;


}

expression :
logic_expression {
    string type = "expression" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  expression : logic_expression\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    SymbolInfo * v = $<symbol>$;
    v->e = new Extra;
    if($<symbol>1->e)
    {
        v->e->returnType = $<symbol>1->e->returnType;
    }    
    else
    {
        printf("had no option at cfg expression logic_expression\n");
        v->e->returnType = "int"; // had no option
    }



    $<symbol>$->code = $<symbol>1->code;
    $<symbol>$->assemblyName = $<symbol>1->assemblyName;



}
| variable ASSIGNOP logic_expression {
    string type = "expression" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  expression : variable ASSIGNOP logic_expression\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    SymbolInfo *var = $<symbol>1;
    SymbolInfo *le = $<symbol>3;
    
    string retv = var->e->returnType;
    string retle = le->e->returnType;
    
    //printf("1. %s %s\n",var->getSymbol().c_str(),retv.c_str());

    //printf("2. %s %s\n",le->getSymbol().c_str(),retle.c_str());

    SymbolInfo * v = $<symbol>$;
    v->e = new Extra;
    
    if(retv.compare(retle)==0)
    {
        v->e->returnType = retv;

    }
    else
    {
        errorCount++;
        fprintf(logFile,"ERROR at line no %d : type mismatch in assignment operator\n\n",lineCount,$<symbol>3->getSymbol().c_str());
        fprintf(errorFile,"ERROR at line no %d : type mismatch in assignment operator\n\n",lineCount,$<symbol>3->getSymbol().c_str());
           
        if(retle.compare("float")==0 && retv.compare("int")==0)
        {
            warningCount++;
            fprintf(logFile,"WARNING at line no %d : auto type conversion from float to int for %s \n\n",lineCount,$<symbol>3->getSymbol().c_str());
            fprintf(errorFile,"WARNING at line no %d : auto type conversion from float to int for %s \n\n",lineCount,$<symbol>3->getSymbol().c_str());
            
            v->e->returnType = retv;
        }
        else if(retle.compare("int")==0 && retv.compare("float")==0)
        {
            warningCount++;
            fprintf(logFile,"WARNING at line no %d : auto type conversion from int to float for %s \n\n",lineCount,$<symbol>1->getSymbol().c_str());
            fprintf(errorFile,"WARNING at line no %d : auto type conversion from int to float for %s \n\n",lineCount,$<symbol>1->getSymbol().c_str());
            
            v->e->returnType = retv;
        }
        else
        {
            if(retle.compare("void")==0)
            {
                errorCount++;
                fprintf(logFile,"ERROR at line no %d : function %s is a void function\n\n",lineCount,$<symbol>3->getSymbol().c_str());
                fprintf(errorFile,"ERROR at line no %d : function %s is a void function\n\n",lineCount,$<symbol>3->getSymbol().c_str());
           
            }

            if(retv.compare("float")||retv.compare("int"))
            {
                v->e->returnType = retv;
        
            }
            else
            {
                printf("Had no option at cfg expression : variable ASSIGNOP logic_expression\n");
                v->e->returnType = "int";
            }
                
        }

    }



    string assemblyCode;
    assemblyCode = assemblyCode + $<symbol>1->code;
    assemblyCode = assemblyCode + $<symbol>3->code;
    assemblyCode = assemblyCode + "\tMOV AX, " + $<symbol>3->assemblyName + "\n";
    //printf("hi");
    if($<symbol>1->e==0)
    {
        //printf("%s",$<symbol>1->getSymbol().c_str());
        assemblyCode = assemblyCode + "\tMOV " + $<symbol>1->assemblyName + ", AX\n";
    }
    else
    {
        
        if($<symbol>1->e->is_array==false)
        {
            assemblyCode = assemblyCode + "\tMOV " + $<symbol>1->assemblyName + ", AX\n";
        }
        else
        {
            //printf("%s\n",$<symbol>1->assemblyName.c_str());
            //printf("%s\n",$<symbol>1->indexNumber.c_str());
            assemblyCode = assemblyCode + "\tMOV BX, " + $<symbol>1->indexNumber + "\n";
            assemblyCode = assemblyCode + "\tADD BX, BX\n";
            assemblyCode = assemblyCode + "\tMOV " + $<symbol>1->assemblyName + "[BX], AX\n";
        }


    }
        $<symbol>$->code = assemblyCode;
    //printf("looking for assignop %s",assemblyCode.c_str());
    $<symbol>$->assemblyName = $<symbol>1->assemblyName;

}

logic_expression :
rel_expression {
    string type = "logic_expression" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  logic_expression : rel_expression\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    SymbolInfo * v = $<symbol>$;
    v->e = new Extra;
    if($<symbol>1->e)
    {
        v->e->returnType = $<symbol>1->e->returnType;
    }    
    else
    {
        printf("had no option at cfg logic_expression rel_expression term\n");
        v->e->returnType = "int"; // had no option
    }


    $<symbol>$->code = $<symbol>1->code;
    $<symbol>$->assemblyName = $<symbol>1->assemblyName;


}
| rel_expression LOGICOP rel_expression {
    string type = "logic_expression" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  logic_expression : rel_expression LOGICOP rel_expression\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());


    SymbolInfo * v = $<symbol>$;
    v->e = new Extra;
    v->e->returnType = "int";



    string assemblyCode ;
    assemblyCode = assemblyCode + $<symbol>1->code;
    assemblyCode = assemblyCode + $<symbol>3->code;


    string t1 = string(newTemp());
    currentFunctionPointer->assemblyFunctionTempVariableName.push_back(t1);
    string l1 = string(newLabel());
    string l2 = string(newLabel());
    string l3 = string(newLabel());

    if($<symbol>2->getSymbol()=="&&")
    {
        
        assemblyCode = assemblyCode + "\tMOV AX, " + $<symbol>1->assemblyName + "\n";
        assemblyCode = assemblyCode + "\tCMP AX, 0\n";
        assemblyCode = assemblyCode + "\tJE " + l1 + "\n";
        assemblyCode = assemblyCode + "\tMOV AX, " + $<symbol>3->assemblyName + "\n";
        assemblyCode = assemblyCode + "\tCMP AX, 0\n";
        assemblyCode = assemblyCode + "\tJE "+ l1 + "\n";
        assemblyCode = assemblyCode + l2 + ":\n";
        assemblyCode = assemblyCode + "\tMOV " + t1 + ", 1\n";
        assemblyCode = assemblyCode + "\tJMP " + l3 + "\n";
        assemblyCode = assemblyCode + l1 + ":\n";
        assemblyCode = assemblyCode + "\tMOV " + t1 + ", 0\n";
        assemblyCode = assemblyCode + l3 + ":\n";
    }
    else if($<symbol>2->getSymbol()=="||")
    {
        assemblyCode = assemblyCode + "\tMOV AX, " + $<symbol>1->assemblyName + "\n";
        assemblyCode = assemblyCode + "\tCMP AX, 0\n";
        assemblyCode = assemblyCode + "\tJNE "+ l1 + "\n";
        assemblyCode = assemblyCode + "\tMOV AX, " + $<symbol>3->assemblyName + "\n";
        assemblyCode = assemblyCode + "\tCMP AX, 0\n";
        assemblyCode = assemblyCode + "\tJNE " + l1 + "\n";
        assemblyCode = assemblyCode + l2 + ":\n";
        
        assemblyCode = assemblyCode + "\tMOV " + t1 + ", 0\n";
        assemblyCode = assemblyCode + "\tJMP " + l3 + "\n";
        assemblyCode = assemblyCode + l1 + ":\n";
        assemblyCode = assemblyCode + "\tMOV " + t1 + " , 1\n";
        assemblyCode = assemblyCode + l3 + ":\n";
    }

    
    $<symbol>$->assemblyName = t1;
    variableNames.push_back(t1);
    $<symbol>$->code = assemblyCode;
}

rel_expression :
simple_expression {
    string type = "rel_expression" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  rel_expression : simple_expression\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());


    SymbolInfo * v = $<symbol>$;
    v->e = new Extra;
    if($<symbol>1->e)
    {
        v->e->returnType = $<symbol>1->e->returnType;
    }    
    else
    {
        printf("had no option at cfg rel_expression simple_expression \n");
        v->e->returnType = "int"; // had no option
    }



    $<symbol>$->code = $<symbol>1->code;
    $<symbol>$->assemblyName = $<symbol>1->assemblyName;


}
| simple_expression RELOP simple_expression {
    string type = "rel_expression" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  rel_expression : simple_expression RELOP simple_expression\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());




    //SymbolInfo* se1 = $<symbol>1;
    //SymbolInfo* se2 = $<symbol>3;
    SymbolInfo * v = $<symbol>$;
    v->e = new Extra;
    v->e->returnType = "int";
    /*if(se1->e->returnType.compare("float")==0  || se2->e->returnType.compare("float")==0)
    {
        v->e->returnType = "int";
        if(se1->e->returnType.compare("float")==0)
        {
            warningCount++;
            fprintf(logFile,"WARNING at line no %d : auto type conversion from float to int for %s \n\n",lineCount,se1->getSymbol().c_str());
            fprintf(errorFile,"WARNING at line no %d : auto type conversion from float to int for %s \n\n",lineCount,se1->getSymbol().c_str());
        
        }
        if(se2->e->returnType.compare("float")==0)
        {
            warningCount++;
            fprintf(logFile,"WARNING at line no %d : auto type conversion from float to int for %s \n\n",lineCount,se2->getSymbol().c_str());
            fprintf(errorFile,"WARNING at line no %d : auto type conversion from float to int for %s \n\n",lineCount,se2->getSymbol().c_str());
        

        }
    }
    else if(se1->e->returnType.compare("int")==0  && se2->e->returnType.compare("int")==0)
    {
        v->e->returnType = "int";
        
    }
    else
    {
        printf("don't know what happened in the cfg simple_expression RELOP simple_expression term\n");
        v->e->returnType = "int";
    }*/


    string assemblyCode = $<symbol>1->code;
    assemblyCode = assemblyCode + $<symbol>3->code;
    string t1 = string(newTemp());
    currentFunctionPointer->assemblyFunctionTempVariableName.push_back(t1);
    string l1 = string(newLabel());
    string l2 = string(newLabel());



    assemblyCode = assemblyCode + "\tMOV AX, " + $<symbol>1->assemblyName + "\n";
    assemblyCode = assemblyCode + "\tCMP AX, " + $<symbol>3->assemblyName + "\n";

    string sym = $<symbol>2->getSymbol();

    if(sym.compare("!=")==0)
    {
        assemblyCode = assemblyCode + "\tJNE " + l1 + "\n";
    }
    else if(sym.compare("==")==0)
    {
        assemblyCode = assemblyCode + "\tJE " + l1 + "\n";
    }
    else if(sym.compare(">=")==0)
    {
        assemblyCode = assemblyCode + "\tJGE " + l1 + "\n";
    }
    else if(sym.compare("<=")==0)
    {
        assemblyCode = assemblyCode + "\tJLE " + l1 + "\n";
    }
    else if(sym.compare(">")==0)
    {
        assemblyCode = assemblyCode + "\tJG " + l1 + "\n";
    }
    else if(sym.compare("<")==0)
    {
        assemblyCode = assemblyCode + "\tJL " + l1 + "\n";
    }

    assemblyCode = assemblyCode + "\tMOV " + t1 + ", 0\n";
    assemblyCode = assemblyCode + "\tJMP " + l2 + "\n";
    assemblyCode = assemblyCode + l1 + ":\n";
    assemblyCode = assemblyCode + "\tMOV " + t1 + ", 1\n";
    assemblyCode = assemblyCode + l2 + ":\n";
    variableNames.push_back(t1);

    $<symbol>$->code = assemblyCode;
    $<symbol>$->assemblyName = t1;





}

simple_expression :
term {
    string type = "simple_expression" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  simple_expression : term\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());



    SymbolInfo * v = $<symbol>$;
    v->e = new Extra;
    if($<symbol>1->e)
    {
        v->e->returnType = $<symbol>1->e->returnType;
    }    
    else
    {
        printf("had no option at cfg simple_expression term\n");
        v->e->returnType = "int"; // had no option
    }


    $<symbol>$->code = $<symbol>1->code;
    $<symbol>$->assemblyName = $<symbol>1->assemblyName;


}
| simple_expression ADDOP term {
    string type = "simple_expression" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  simple_expression : simple_expression ADDOP term\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());





    SymbolInfo* se = $<symbol>1;
    SymbolInfo* t1 = $<symbol>3;
    SymbolInfo * v = $<symbol>$;
    v->e = new Extra;
    if(t1->e->returnType.compare("float")==0  || se->e->returnType.compare("float")==0)
    {
        v->e->returnType = "float";
        if(t1->e->returnType.compare("int")==0)
        {
            warningCount++;
            fprintf(logFile,"WARNING at line no %d : auto type conversion from int to float for %s \n\n",lineCount,t1->getSymbol().c_str());
            fprintf(errorFile,"WARNING at line no %d : auto type conversion from int to float for %s \n\n",lineCount,t1->getSymbol().c_str());
        
        }
        else if(se->e->returnType.compare("int")==0)
        {
            warningCount++;
            fprintf(logFile,"WARNING at line no %d : auto type conversion from int to float for %s \n\n",lineCount,se->getSymbol().c_str());
            fprintf(errorFile,"WARNING at line no %d : auto type conversion from int to float for %s \n\n",lineCount,se->getSymbol().c_str());
        

        }
    }
    else if(t1->e->returnType.compare("int")==0  && se->e->returnType.compare("int")==0)
    {
        v->e->returnType = "int";
        
    }
    else
    {
        printf("don't know what happened in the cfg simple_expression addop term\n");
        v->e->returnType = "int";
    }



    string assemblyCode;
    string temp1 = string(newTemp());
    currentFunctionPointer->assemblyFunctionTempVariableName.push_back(temp1);
    string sym = $<symbol>2->getSymbol();

    assemblyCode = assemblyCode + $<symbol>1->code + $<symbol>3->code;
    assemblyCode = assemblyCode + "\tMOV AX, " + $<symbol>1->assemblyName + "\n";
    
    if(sym.compare("+")==0)
    {
        assemblyCode = assemblyCode + "\tADD AX, " + $<symbol>3->assemblyName + "\n";
    }
    else
    {
        assemblyCode = assemblyCode + "\tSUB AX, " + $<symbol>3->assemblyName + "\n";
    }

    assemblyCode = assemblyCode + "\tMOV " + temp1 + " , AX\n";
    
    $<symbol>$->code = assemblyCode;
    $<symbol>$->assemblyName = temp1;
    variableNames.push_back(temp1);



}

term :
unary_expression {
    string type = "term" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  term : unary_expression\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    SymbolInfo * v = $<symbol>$;
    v->e = new Extra;
    if($<symbol>1->e)
    {
        v->e->returnType = $<symbol>1->e->returnType;
    }    
    else
    {
        printf("had no option at cfg term unary_expression\n");
        v->e->returnType = "int"; // had no option
    }


    $<symbol>$->code = $<symbol>1->code;
    $<symbol>$->assemblyName = $<symbol>1->assemblyName;


}
| term MULOP unary_expression {
    string type = "term" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  term : term MULOP unary_expression\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    SymbolInfo* t1 = $<symbol>1;
    SymbolInfo* ue = $<symbol>3;
    SymbolInfo * v = $<symbol>$;
    v->e = new Extra;
    if(t1->e->returnType.compare("float")==0  || ue->e->returnType.compare("float")==0)
    {
        if($<symbol>2->getSymbol().compare("%")==0)
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : for expression %s both operand of modulus operator should be integer \n\n",lineCount,symbol.c_str());
            fprintf(errorFile,"ERROR at line no %d : for expression %s both operand of modulus operator should be integer \n\n",lineCount,symbol.c_str());
        
        }
        v->e->returnType = "float";
        if(t1->e->returnType.compare("int")==0)
        {
            warningCount++;
            fprintf(logFile,"WARNING at line no %d : auto type conversion from int to float for %s \n\n",lineCount,t1->getSymbol().c_str());
            fprintf(errorFile,"WARNING at line no %d : auto type conversion from int to float for %s \n\n",lineCount,t1->getSymbol().c_str());
        
        }
        else if(ue->e->returnType.compare("int")==0)
        {
            warningCount++;
            fprintf(logFile,"WARNING at line no %d : auto type conversion from int to float for %s \n\n",lineCount,ue->getSymbol().c_str());
            fprintf(errorFile,"WARNING at line no %d : auto type conversion from int to float for %s \n\n",lineCount,ue->getSymbol().c_str());
        

        }
    }
    else if(t1->e->returnType.compare("int")==0  && ue->e->returnType.compare("int")==0)
    {
        v->e->returnType = "int";
        
    }
    else
    {
        printf("don't know what happened in the cfg term mulop unary_expression\n");
        v->e->returnType = "int";
    }




    string sym = $<symbol>2->getSymbol();
    string assemblyCode;
    assemblyCode = assemblyCode + $<symbol>1->code + $<symbol>3->code;
    string temp1 = string(newTemp());
    currentFunctionPointer->assemblyFunctionTempVariableName.push_back(temp1);
    assemblyCode = assemblyCode + "\tMOV AX, " + $<symbol>1->assemblyName + "\n";
    assemblyCode = assemblyCode + "\tMOV BX, " + $<symbol>3->assemblyName + "\n";
        
    
    if(sym.compare("/")==0)
    {
        assemblyCode = assemblyCode + "\tDIV BX\n";
        assemblyCode = assemblyCode + "\tMOV " + temp1 + ", AX\n";
    }
    else if(sym.compare("%")==0)
    {
        assemblyCode = assemblyCode + "\tMOV DX, 0\n";
        assemblyCode = assemblyCode + "\tDIV BX \n";
        assemblyCode = assemblyCode + "\tMOV " + temp1 + ", DX\n";
        

    }
    else if(sym.compare("*")==0)
    {
        assemblyCode = assemblyCode + "\tMUL BX \n";
        assemblyCode = assemblyCode + "\tMOV " + temp1 + ", AX\n";
    }



    $<symbol>$->code = assemblyCode;
    $<symbol>$->assemblyName = temp1;
    variableNames.push_back(temp1);
    





}

unary_expression : 
ADDOP unary_expression {
    string type = "unary_expression" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  unary_expression : ADDOP unary_expression\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    SymbolInfo * v = $<symbol>$;
    v->e = new Extra;
    if($<symbol>2->e)
    {
        v->e->returnType = $<symbol>2->e->returnType;
    }    
    else
    {
        printf("had no option at cfg addop unary_expression\n");
        
        v->e->returnType = "int"; // had no option
    }




    string sym = $<symbol>1->getSymbol();
    string assemblyCode;
    assemblyCode = assemblyCode + $<symbol>2->code;
        
    
    
    if(sym.compare("-")==0)
    {
        assemblyCode = assemblyCode + "\tMOV AX, " + $<symbol>2->assemblyName + "\n";
        assemblyCode = assemblyCode + "\tNEG AX \n";
        assemblyCode = assemblyCode + "\tMOV " + $<symbol>2->assemblyName + ", AX\n";

    }

    $<symbol>$->code = assemblyCode;
    $<symbol>$->assemblyName = $<symbol>2->assemblyName;



}
| NOT unary_expression {
    string type = "unary_expression" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  unary_expression : NOT unary_expression\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    SymbolInfo * v = $<symbol>$;
    v->e = new Extra;
    if($<symbol>2->e)
    {
        v->e->returnType = $<symbol>2->e->returnType;
    }    
    else
    {
        printf("had no option at cfg not unary_expression\n");
        
        v->e->returnType = "int"; // had no option

    }



    string assemblyCode = $<symbol>2->code;
    assemblyCode = assemblyCode + "\tMOV AX, " + $<symbol>2->assemblyName + "\n";
    assemblyCode = assemblyCode + "\tNOT AX\n";
    assemblyCode = assemblyCode + "\tMOV " + $<symbol>2->assemblyName + ", AX\n";


    $<symbol>$->code = assemblyCode;
    $<symbol>$->assemblyName = $<symbol>2->assemblyName;



}
| factor {
    string type = "unary_expression" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  unary_expression : factor\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    SymbolInfo * v = $<symbol>$;
    v->e = new Extra;
    if($<symbol>1->e)
    {
        v->e->returnType = $<symbol>1->e->returnType;
    }    
    else
    {
        //printf("had no option at cfg unary_expression factor %s\n",symbol.c_str());

        
        v->e->returnType = "int"; // had no option
    }

    $<symbol>$->code = $<symbol>1->code;
    $<symbol>$->assemblyName = $<symbol>1->assemblyName;

}

factor :
variable {
    string type = "factor" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    $<symbol>$->e = new Extra;
    //SymbolInfo* v = $<symbol>1;
    $<symbol>$->e->returnType = $<symbol>1->e->returnType;
    fprintf(logFile,"At line no : %d  factor : variable\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());


    string assemblyCode;
    assemblyCode = assemblyCode + $<symbol>1->code;
    if($<symbol>1->e!=0)
    {
        if($<symbol>1->e->is_array==true)
        {
            string temp1 = string(newTemp());
            currentFunctionPointer->assemblyFunctionTempVariableName.push_back(temp1);
            assemblyCode = assemblyCode + "\tMOV AX, " + $<symbol>1->assemblyName + "[BX]\n";
            assemblyCode = assemblyCode + "\tMOV " + temp1 + ", AX\n";
            variableNames.push_back(temp1);
            $<symbol>$->assemblyName = temp1;
        }
        else
        {
            $<symbol>$->assemblyName = $<symbol>1->assemblyName;
        }

    }
    else
    {
        $<symbol>$->assemblyName = $<symbol>1->assemblyName;
    }

    $<symbol>$->code = assemblyCode;
    


}
| ID LPAREN argument_list RPAREN {
    string type = "factor" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol()+" "+$<symbol>4->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    
    fprintf(logFile,"At line no : %d  factor : ID LPAREN argument_list RPAREN\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    SymbolInfo * v = $<symbol>$;
    v->e = new Extra;
    string symbol1 = $<symbol>1->getSymbol();
    SymbolInfo* found = st->lookUp(symbol1);

    if(found==0)
    {
        errorCount++;
        fprintf(logFile,"ERROR at line no %d : function name %s is not declared \n\n",lineCount,symbol.c_str());
        fprintf(errorFile,"ERROR at line no %d : function name %s is not declared \n\n",lineCount,symbol.c_str());
        
        v->e->returnType = "int"; // error so in order to keep the code running i had no other option
    
    }
    else
    {
        if(found->e->is_function==false)
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : ID %s is not a function it is a variable \n\n",lineCount,$<symbol>1->getSymbol().c_str());
            fprintf(errorFile,"ERROR at line no %d : ID %s is not a function it is a variable \n\n",lineCount,$<symbol>1->getSymbol().c_str());
            
        }
        vector<string> varType = found->typeSpecifier;
        //printf("%d \n",found->typeSpecifier.size());
        int s1 = varType.size();
        int s2 = argumentList.size();
        int s;
        //printf("%d %d %s\n",s1,s2,found->getSymbol().c_str());
        if(s1!=s2)
        {
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : for function %s argument size doesn't match with function definition \n\n",lineCount,$<symbol>1->getSymbol().c_str());
            fprintf(errorFile,"ERROR at line no %d : for function %s argument size doesn't match with function definition \n\n",lineCount,$<symbol>1->getSymbol().c_str());
            
            //printf("%s %d %d\n",$<symbol>1->getSymbol().c_str(),s1,s2);

        }
        else
        {
            for(int i=0;i<varType.size();i++)
            {
                if(varType[i].compare(argumentList[i])!=0)
                {
                    if(argumentList[i].compare("float")==0)
                    {
                        warningCount++;
                        fprintf(logFile,"WARNING at line no %d : auto type conversion from float to int in fuction %s for parameter number %d\n\n",lineCount,$<symbol>1->getSymbol().c_str(),i+1);
                        fprintf(errorFile,"WARNING at line no %d : auto type conversion from float to int in fuction %s for parameter number %d\n\n",lineCount,$<symbol>1->getSymbol().c_str(),i+1);
            
                    }
                    else if(argumentList[i].compare("int")==0)
                    {
                        warningCount++;
                        fprintf(logFile,"WARNING at line no %d : auto type conversion from int to float in fuction %s for parameter number %d\n\n",lineCount,$<symbol>1->getSymbol().c_str(),i);
                        fprintf(errorFile,"WARNING at line no %d : auto type conversion from int to float in fuction %s for parameter number %d\n\n",lineCount,$<symbol>1->getSymbol().c_str(),i);
            
                    }
                    else
                    {
                        errorCount++;
                        fprintf(logFile,"ERROR at line no %d : for function %s argument serial doesn't match with function definition \n\n",lineCount,$<symbol>1->getSymbol().c_str());
                        fprintf(errorFile,"ERROR at line no %d : for function %s argument serial doesn't match with function definition \n\n",lineCount,$<symbol>1->getSymbol().c_str());
        
                    }
                    
                }
            }

        }


        
            string assemblyCode = $<symbol>3->code;
            string temp1 = string(newTemp());
            currentFunctionPointer->assemblyFunctionTempVariableName.push_back(temp1);
            
            // icg code should be written here 
            //************************************
            //*************************************
            // for(int i=0;i<found->assemblyFunctionVariableName.size();i++)
            // {
            //     assemblyCode = assemblyCode + "\tPUSH " + found->assemblyFunctionVariableName[i];
            // }
            for(int i=0;i<found->assemblyParameterName.size();i++)
            {
                
                assemblyCode = assemblyCode + "\tPUSH " + found->assemblyParameterName[i] + "\n";
                //assemblyCode = assemblyCode + "\tMOV " + found->assemblyParameterName[i] + ", AX\n";
            }
            for(int i=0;i<found->assemblyParameterName.size();i++)
            {
                
                assemblyCode = assemblyCode + "\tMOV AX, " + argumentSymbols[i]->assemblyName + "\n";
                assemblyCode = assemblyCode + "\tMOV " + found->assemblyParameterName[i] + ", AX\n";
            }

            assemblyCode = assemblyCode + "\tCALL "+$<symbol>1->getSymbol()+"\n";
            assemblyCode = assemblyCode + "\tMOV AX, " + $<symbol>1->getSymbol()+ "_return\n";
            assemblyCode = assemblyCode + "\tMOV " + temp1 + ", AX\n";
            for(int i=found->assemblyParameterName.size()-1;i>=0;i--)
            {
                
                assemblyCode = assemblyCode + "\tPOP " + found->assemblyParameterName[i] + "\n";
                //assemblyCode = assemblyCode + "\tMOV " + found->assemblyParameterName[i] + ", AX\n";
            }
            $<symbol>$->code = assemblyCode ;
            variableNames.push_back(temp1);
            $<symbol>$->assemblyName = temp1;
        

        argumentSymbols.clear();

        argumentList.clear();
        string ret = found->e->returnType;
        //printf("%s\n",ret.c_str());
        v->e->returnType = ret;

        //code portion below not needed anymore
        /*if(ret.compare("int")==0 || ret.compare("float")==0)
        {
            
        }
        else
        {
            //printf("had no option at cfg factor id LPAREN argument_list\n");
            errorCount++;
            fprintf(logFile,"ERROR at line no %d : function name %s is a void function \n\n",lineCount,found->getSymbol().c_str());
            fprintf(errorFile,"ERROR at line no %d : function name %s is a void function \n\n",lineCount,found->getSymbol().c_str());
        
            v->e->returnType = "int";
        }*/

        // we have to write more code to check the appropiate arguments
    }







}
| LPAREN expression RPAREN {
    string type = "factor" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  factor : LPAREN expression RPAREN\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());



    SymbolInfo * v = $<symbol>$;
    v->e = new Extra;
    if($<symbol>2->e)
    {
        v->e->returnType = $<symbol>2->e->returnType;
    }    
    else
    {
        printf("had no option at cfg LPAREN expression RPAREN %s\n",symbol.c_str());
        v->e->returnType = "int"; // had no option
    }


    $<symbol>$->assemblyName = $<symbol>2->assemblyName;
    $<symbol>$->code = $<symbol>2->code;
   

}
| CONST_INT {
    string type = "factor" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    $<symbol>$->e = new Extra;
    SymbolInfo* v = $<symbol>$;
    v->e->returnType = "int";
    fprintf(logFile,"At line no : %d  factor : CONST_INT\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());


    string temp1 = string(newTemp());
    currentFunctionPointer->assemblyFunctionTempVariableName.push_back(temp1);
    string assemblyCode;
    assemblyCode = assemblyCode + "\tMOV " + temp1 + ", " + $<symbol>1->getSymbol() + "\n";
    $<symbol>$->code = assemblyCode;
    $<symbol>$->assemblyName = temp1;
    variableNames.push_back(temp1);


}
| CONST_FLOAT {
    string type = "factor" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    $<symbol>$->e = new Extra;
    SymbolInfo* v = $<symbol>$;
    v->e->returnType = "float";
    fprintf(logFile,"At line no : %d  factor : CONST_FLOAT\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());


    string temp1 = string(newTemp());
    currentFunctionPointer->assemblyFunctionTempVariableName.push_back(temp1);
    string assemblyCode;
    assemblyCode = assemblyCode + "\tMOV " + temp1 + ", " + $<symbol>1->getSymbol() + "\n";
    $<symbol>$->code = assemblyCode;
    $<symbol>$->assemblyName = temp1;
    variableNames.push_back(temp1);


}
| variable INCOP {
    string type = "factor" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  factor : variable INCOP\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    //$<symbol>$ = new SymbolInfo(symbol,type);
    $<symbol>$->e = new Extra;
    //SymbolInfo* v = $<symbol>1;
    $<symbol>$->e->returnType = $<symbol>1->e->returnType;



    SymbolInfo* t1 = $<symbol>1;
    string temp1 = string(newTemp());
    currentFunctionPointer->assemblyFunctionTempVariableName.push_back(temp1);
    string assemblyCode ;
    if(t1->e==0)
    {
        assemblyCode = assemblyCode + "\tMOV AX, " + $<symbol>1->assemblyName + "\n";
        
    }
    else
    {
        if(t1->e->is_array==true)
        {
            assemblyCode = assemblyCode + "\tMOV AX, " + $<symbol>1->assemblyName + "[BX]\n";
        }
        else
        {
            assemblyCode = assemblyCode + "\tMOV AX, " + $<symbol>1->assemblyName + "\n";
        }

    }
    assemblyCode = assemblyCode + "\tMOV " + temp1 + ", AX\n";
    if(t1->e==0)
    {
        assemblyCode = assemblyCode + "\tINC " + $<symbol>1->assemblyName + "\n";
        
    }
    else
    {
        if(t1->e->is_array==true)
        {
            assemblyCode = assemblyCode + "\tMOV AX, " + $<symbol>1->assemblyName + "[BX]\n";
            assemblyCode = assemblyCode + "\tINC AX\n";
            assemblyCode = assemblyCode + "\tMOV " + $<symbol>1->assemblyName + "[BX], AX\n";
        }
        else
        {
            assemblyCode = assemblyCode + "\tINC " + $<symbol>1->assemblyName + "\n";
        }

    }


    variableNames.push_back(temp1);
    $<symbol>$->code = assemblyCode;
    $<symbol>$->assemblyName = temp1;


}
| variable DECOP {
    string type = "factor" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  factor : variable DECOP\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    //$<symbol>$ = new SymbolInfo(symbol,type);
    $<symbol>$->e = new Extra;
    //SymbolInfo* v = $<symbol>1;
    $<symbol>$->e->returnType = $<symbol>1->e->returnType;




    SymbolInfo* t1 = $<symbol>1;
    string temp1 = string(newTemp());
    currentFunctionPointer->assemblyFunctionTempVariableName.push_back(temp1);
    string assemblyCode ;
    if(t1->e==0)
    {
        assemblyCode = assemblyCode + "\tMOV AX, " + $<symbol>1->assemblyName + "\n";
        
    }
    else
    {
        if(t1->e->is_array==true)
        {
            assemblyCode = assemblyCode + "\tMOV AX, " + $<symbol>1->assemblyName + "[BX]\n";
        }
        else
        {
            assemblyCode = assemblyCode + "\tMOV AX, " + $<symbol>1->assemblyName + "\n";
        }

    }
    assemblyCode = assemblyCode + "\tMOV " + temp1 + ", AX\n";
    if(t1->e==0)
    {
        assemblyCode = assemblyCode + "\tDEC " + $<symbol>1->assemblyName + "\n";
        
    }
    else
    {
        if(t1->e->is_array==true)
        {
            assemblyCode = assemblyCode + "\tMOV AX, " + $<symbol>1->assemblyName + "[BX]\n";
            assemblyCode = assemblyCode + "\tDEC AX\n";
            assemblyCode = assemblyCode + "\tMOV " + $<symbol>1->assemblyName + "[BX], AX\n";
        }
        else
        {
            assemblyCode = assemblyCode + "\tDEC " + $<symbol>1->assemblyName + "\n";
        }

    }


    variableNames.push_back(temp1);
    $<symbol>$->code = assemblyCode;
    $<symbol>$->assemblyName = temp1;

}

argument_list : 
arguments {
    string type = "argument_list" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  argument_list : arguments\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());



    $<symbol>$->code = $<symbol>1->code;

}
| {

    string type = "argument_list" ;
    string symbol = "";
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  argument_list : \n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

}

arguments :
arguments COMMA logic_expression {
    string type = "arguments" ;
    string symbol = $<symbol>1->getSymbol()+" "+$<symbol>2->getSymbol()+" "+$<symbol>3->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  arguments : arguments COMMA logic_expression\n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());

    argumentList.push_back($<symbol>3->e->returnType.c_str());



    $<symbol>$->code = $<symbol>1->code+$<symbol>3->code;
    argumentSymbols.push_back($<symbol>3);
}
| logic_expression {
    string type = "argument_list" ;
    string symbol = $<symbol>1->getSymbol();
    $<symbol>$ = new SymbolInfo(symbol,type);
    fprintf(logFile,"At line no : %d  arguments : logic_expression \n\n",lineCount);
    fprintf(logFile,"%s\n\n",symbol.c_str());
    argumentList.push_back($<symbol>1->e->returnType.c_str());
    argumentSymbols.push_back($<symbol>1);
    $<symbol>$->code = $<symbol>1->code;

}




%%

/*
int lineCount = 1;
int errorCount = 0;
SymbolTable *st;
FILE *inputFile;
FILE *errorFile;
FILE *logFile;

extern FILE *yyin;

int yylex();
int yyparse();
*/

int main(int argc, char *argv[])
{
    inputFile = fopen(argv[1],"r");
    if(!inputFile)
    {
        printf("Couldn't open input file\n");
        return 0;
    }
    
    //st = new SymbolTable(bucketLength);
    errorFile = fopen("log.txt","w");
    string logFileName = "1605062_log.txt";
    logFile = fopen("1605062_log.txt","w");
    
    yyin = inputFile;
    yyparse();
    
    //symbol table should be printed here in logfile
    fprintf(logFile,"total lines in the code are %d\n\n",lineCount);
    fprintf(logFile,"total warnings in the code are %d\n\n",warningCount);
    fprintf(logFile,"total errors in the code are %d\n\n",errorCount);
    fprintf(logFile,"\n\n");
    fprintf(errorFile,"total lines in the code are %d\n\n",lineCount);
    fprintf(errorFile,"total warnings in the code are %d\n\n",warningCount);
    fprintf(errorFile,"total errors in the code are %d\n\n",errorCount);
    fprintf(errorFile,"\n\n");
    

    st->printFile(logFile);
    fclose(inputFile);
    fclose(errorFile);
    fclose(logFile);
    remove(logFileName.c_str());
    
    
}




