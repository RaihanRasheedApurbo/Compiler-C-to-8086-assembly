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
using namespace std;

int line_count=1;
int bucketLength = 10;

string s = "";
string comment ="";

FILE *logout;
FILE *tokenout;
int errorCount = 0;
int commentLine = 0;





class SymbolInfo
{
    string name;
    string type;
    SymbolInfo* next;

public:

    SymbolInfo* getNext();
    string getSymbol();
    string getType();
    void setSymbol(string symbol);
    void setType(string type);
    void setNext(SymbolInfo* n);
    SymbolInfo();
    SymbolInfo(string name,string type);
    ~SymbolInfo();
};

SymbolInfo::~SymbolInfo()
{
    //cout<<"symbol info destructor called"<<endl;
}
SymbolInfo::SymbolInfo()
{
    next =0;
}
SymbolInfo::SymbolInfo(string name,string type)
{
    this->name = name;
    this->type = type;
    next = 0;
}

void SymbolInfo::setSymbol(string symbol)
{
    name = symbol;
}

void SymbolInfo::setType(string type)
{
    this->type = type;
}

void SymbolInfo::setNext(SymbolInfo* n)
{
    next = n;
}

string SymbolInfo::getSymbol()
{
    return name;
}

string SymbolInfo::getType()
{
    return type;
}

SymbolInfo* SymbolInfo::getNext()
{
    return this->next;
}

class ScopeTable
{
    SymbolInfo **arr;
    ScopeTable *parent;
    int bucketLength;
    int hashFunc(string symbol);
public:
    ScopeTable(int bucketLength);
    void setParent(ScopeTable *p);
    ScopeTable* getParent();
    bool insertion(SymbolInfo *entry);
    SymbolInfo* lookUp(string symbol);
    bool deletion(string symbol);
    void print();
    void printPosition(string symbol);
    void printFile();
    ~ScopeTable();
};

void ScopeTable::printFile()
{
    for(int i=0; i<bucketLength; i++)
    {
        FILE *ptr = logout;
        bool notEmpty = false;
        SymbolInfo* temp = arr[i];
        if(temp!=0)
        {
            //cout<<i<<"--->  ";
            fprintf(ptr,"%d--> ",i);
            notEmpty = true;
        }
        while(temp!=0)
        {
            //cout<<"<"<<temp->getSymbol()<<" : "<<temp->getType()<<"> ";
            fprintf(ptr,"<%s : %s> ",temp->getSymbol().c_str(),temp->getType().c_str());
            temp=temp->getNext();
        }
        if(notEmpty)
        {
            notEmpty = false;
            fprintf(ptr,"\n");
        }
        //cout<<endl<<endl;
    }
}

ScopeTable::~ScopeTable()
{
    for(int i=0; i<bucketLength; i++)
    {
        SymbolInfo* temp = arr[i];
        while(temp!=0)
        {

            this->deletion(temp->getSymbol());
            temp = arr[i];
        }
    }
    delete []arr;
    //cout<<"scopeTable deleted"<<endl;
}


ScopeTable::ScopeTable(int bucketLength)
{
    parent = 0;
    this->bucketLength = bucketLength;
    arr = new SymbolInfo* [bucketLength];
    for(int i=0; i<bucketLength; i++)
    {
        arr[i]=0;
    }

}

void ScopeTable::setParent(ScopeTable* p)
{
    parent = p;
}

ScopeTable* ScopeTable::getParent()
{
    return parent;
}
SymbolInfo* ScopeTable::lookUp(string symbol)
{
    int ind = hashFunc(symbol);
    //printf("%s\n",symbol.c_str());
    //printf("%d\n",ind);
    SymbolInfo *temp = arr[ind];
    //int k = temp;
    //printf("%p\n",temp);
    //int position = 0;
    while(temp!=0)
    {
        
        if(temp->getSymbol().compare(symbol)==0)
        {
            //printf("%s %s\n",temp->getSymbol().c_str(),symbol.c_str());
            return temp;

        }
        temp=temp->getNext();
    }
    return 0;
}

bool ScopeTable::insertion(SymbolInfo *entry)
{
    string symbol = entry->getSymbol();
    SymbolInfo *found = lookUp(symbol);
    //printf("kill me %p\n",found);
    
    if(found==0)
    {
        int ind = hashFunc(symbol);
        found = arr[ind];
        if(found==0)
        {
            arr[ind]=entry;
        }
        else
        {
            while(found->getNext()!=0)
            {
                found=found->getNext();
            }
            found->setNext(entry);

        }
        return true;
    }
    //printf("kill me again%p\n",found);
    return false;
}



bool ScopeTable::deletion(string symbol)
{
    SymbolInfo* found = lookUp(symbol);
    if(found==0)
    {
        return false;
    }
    int ind = hashFunc(symbol);
    SymbolInfo *temp = arr[ind];
    if(temp==found)
    {
        arr[ind]=temp->getNext();
        delete temp;
    }
    else
    {
        SymbolInfo* parent =0;
        while(temp!=0)
        {

            if(temp==found)
            {
                parent->setNext(temp->getNext());
                delete temp;
                break;
            }
            parent=temp;
            temp=temp->getNext();
        }

    }
    return true;
}

void ScopeTable::print()
{
    for(int i=0; i<bucketLength; i++)
    {
        //cout<<i<<"--->  ";
        SymbolInfo* temp = arr[i];
        while(temp!=0)
        {
            //cout<<"<"<<temp->getSymbol()<<" : "<<temp->getType()<<"> ";
            temp=temp->getNext();
        }
        //cout<<endl<<endl;
    }
}
void ScopeTable::printPosition(string symbol)
{
    SymbolInfo *found=lookUp(symbol);
    if(found==0)
    {
        //cout<<"not found"<<endl;
        return;
    }


    int ind = hashFunc(symbol);
    SymbolInfo *temp = arr[ind];
    int position = 0;
    while(temp)
    {
        if(temp->getSymbol().compare(symbol)==0)
        {
            //cout<<"at position "<<ind<<", "<<position<<endl<<endl;
            return;

        }
        temp=temp->getNext();
        position++;
    }
    return;
}

int ScopeTable::hashFunc(string symbol)
{
    int strlen = symbol.size();
    int ind = 0;
    for(int i=0; i<5; i++)
    {
        if(strlen<=i)
        {
            break;
        }
        ind += symbol[i];
    }
    return ind%bucketLength;
}

class SymbolTable
{
    ScopeTable *current;
    int tableNo;
    int bucketLength;
public:
    //void getPosition(string symbol);
    SymbolTable(int bucketLength);
    bool enterScope();
    bool exitScope();
    bool insertion(SymbolInfo *entry);
    bool removal(string symbol);
    SymbolInfo* lookUp(string symbol);
    void printCurrent();
    void printAll();
    void printFile();
    ~SymbolTable();

};

void SymbolTable::printFile()
{
    current->printFile();

}

SymbolTable::~SymbolTable()
{
    //cout<<"In symboltable destructor"<<endl;
    ScopeTable* parent ;
    while(current!=0)
    {
        //cout<<"calling scope table destructor "<<tableNo<<endl;
        parent=current->getParent();
        tableNo--;
        current->~ScopeTable();
        current=parent;

    }


}

SymbolTable::SymbolTable(int bucketLength)
{
    this->bucketLength = bucketLength;
    current = new ScopeTable(bucketLength);
    tableNo =1;
    current->setParent(0);
}

bool SymbolTable::enterScope()
{

    ScopeTable *child = new ScopeTable(bucketLength);
    child->setParent(current);
    current = child;
    tableNo++;
    //cout<<"New ScopeTable with id "<<tableNo<<" created"<<endl<<endl;
    return true;
}

bool SymbolTable::exitScope()
{
    if(current!=0)
    {
        ScopeTable* parent = current->getParent();
        //cout<<"calling scope table destructor "<<tableNo<<endl;
        current->~ScopeTable();
        //cout<<"ScopeTable with id "<<tableNo<<" remove"<<endl<<endl;
        current=parent;
        tableNo--;
        return true;
    }
    else
        return false;

}

bool SymbolTable::insertion(SymbolInfo* entry)
{
    int result = current->insertion(entry);
    if(result==true)
    {
        //cout<<"Inserted in ScopeTable# "<<tableNo<<" ";
        current->printPosition(entry->getSymbol());
    }
    else
    {
        //cout<<"already exists"<<endl<<endl;
    }
    return result;

}

bool SymbolTable::removal(string symbol)
{
    bool result = current->lookUp(symbol);
    if(result==true)
    {
        //cout<<"deleted entry from current ScopeTable ";
        current->printPosition(symbol);
        current->deletion(symbol);
    }
    else
    {
        //cout<<"not found"<<endl<<endl;

    }
    return result;



}

SymbolInfo* SymbolTable::lookUp(string symbol)
{
    ScopeTable * temp = current;
    SymbolInfo * found =0;
    int tablenumber = tableNo;
    while(temp!=0)
    {
        found =temp->lookUp(symbol);
        if(found!=0)
        {
            //cout<<"found in ScopeTable# "<<tablenumber<<" ";
            temp->printPosition(symbol);
            break;
        }
        temp = temp->getParent();
        tablenumber--;
    }
    if(found==0)
    {
        //cout<<"not found"<<endl<<endl;
    }
    return found;
}

void SymbolTable::printCurrent()
{
    //cout<<"ScopeTable# "<<tableNo<<endl<<endl;
    current->print();
}

void SymbolTable::printAll()
{
    int tablenumber = tableNo;
    ScopeTable* temp = current;
    while(temp!=0)
    {
        //cout<<"ScopeTable# "<<tablenumber<<endl<<endl;
        temp->print();
        temp = temp->getParent();
    }
}

SymbolTable st(bucketLength);




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
    commentLine = line_count;
    BEGIN MCOMMENT0;
}

<MCOMMENT0><<EOF>> {
    fprintf(logout,"Line no %d: Unfinished comment error\n",commentLine);
    errorCount++;
    BEGIN INITIAL;

}

<MCOMMENT0>"*/" {
    //printf("multiline comment found: %s\n",comment.c_str());
    //fprintf(tokenout,"<CONST_CHAR,%c%c>",s1,s2);
	fprintf(logout,"Line no %d: multiline comment found: %s\n",commentLine,comment.c_str());
    BEGIN INITIAL;
}
<MCOMMENT0>\n {
    comment.append("\n");
    line_count++;

}
<MCOMMENT0>. {
    
    
    comment.append(yytext);
}


"//" {
    //printf("starting lcomment0\n");
    comment = "";
    commentLine=line_count;
    BEGIN LCOMMENT0;
}

<LCOMMENT0><<EOF>> {
    //printf("comment found:%s\n",comment.c_str());

	fprintf(logout,"Line no %d: comment found: %s\n",commentLine,comment.c_str());
    BEGIN INITIAL;
}
<LCOMMENT0>\n {
    line_count++;
    fprintf(logout,"Line no %d: comment found: %s\n",commentLine,comment.c_str());
    BEGIN INITIAL;

}
<LCOMMENT0>"\\" {
    //printf("backslash found\n");
    //line_count++;
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
    line_count++;
    BEGIN LCOMMENT0;
}



<LCOMMENT0>. {
    comment.append(yytext);
    //printf("kill me");

}
















["]	{
	s = "";
    commentLine=line_count;
	//printf("starting the state0\n");
	BEGIN STATE0;
}

<STATE0>["] {
    //printf("in state0\n");
    //printf("here should be string %s\n",s.c_str());
    fprintf(tokenout,"<STRING, %s>",s.c_str());
	fprintf(logout,"Line no %d: TOKEN <STRING> Lexeme %s found\n",commentLine,s.c_str());
    BEGIN INITIAL;

}

<STATE0>[\n] {
    
    line_count++;
    fprintf(logout,"Line no %d: Unfinished string error\n",commentLine);
    errorCount++;
    BEGIN INITIAL;

    
    
        
    
}

<STATE0>[\\] {
    //printf("backslash found\n");
    BEGIN STATE1;
}

<STATE1>\n {
    line_count++;
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
        fprintf(logout,"Line no %d: Unknown scape sequence error\n",commentLine);
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
	fprintf(tokenout,"<CONST_CHAR,%c%c>",s1,s2);
	fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %c%c found\n",line_count,s1,s2);
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
    bool v=st.insertion(t);
    //printf("%d",v);
    if(v)
    {
        st.printFile();   
    }
    else
    {
        fprintf(logout,"already exist\n");
    }
}








{NEWLINE} {
	line_count++;
}

"if" {		
	//keyword starts from here
	fprintf(tokenout,"<IF>");
	fprintf(logout,"Line no %d: TOKEN <IF> Lexeme %s found\n",line_count,yytext);
    
}

"else" {
	fprintf(tokenout,"<ELSE>");
	fprintf(logout,"Line no %d: TOKEN <ELSE> Lexeme %s found\n",line_count,yytext);
}

"for"	{
			fprintf(tokenout,"<FOR>");
			fprintf(logout,"Line no %d: TOKEN <FOR> Lexeme %s found\n",line_count,yytext);
		}
"while"	{
			fprintf(tokenout,"<WHILE>");
			fprintf(logout,"Line no %d: TOKEN <WHILE> Lexeme %s found\n",line_count,yytext);
		}

"do"	{
			fprintf(tokenout,"<DO>");
			fprintf(logout,"Line no %d: TOKEN <DO> Lexeme %s found\n",line_count,yytext);
		}

"break"	{
			fprintf(tokenout,"<BREAK>");
			fprintf(logout,"Line no %d: TOKEN <BREAK> Lexeme %s found\n",line_count,yytext);
		}

"int"	{
			fprintf(tokenout,"<INT>");
			fprintf(logout,"Line no %d: TOKEN <INT> Lexeme %s found\n",line_count,yytext);
		}

"char"	{
			fprintf(tokenout,"<CHAR>");
			fprintf(logout,"Line no %d: TOKEN <CHAR> Lexeme %s found\n",line_count,yytext);
		}

"float"	{
			fprintf(tokenout,"<FLOAT>");
			fprintf(logout,"Line no %d: TOKEN <FLOAT> Lexeme %s found\n",line_count,yytext);
		}

"double"	{
			fprintf(tokenout,"<DOUBLE>");
			fprintf(logout,"Line no %d: TOKEN <DOUBLE> Lexeme %s found\n",line_count,yytext);
		}

"void"	{
			fprintf(tokenout,"<VOID>");
			fprintf(logout,"Line no %d: TOKEN <VOID> Lexeme %s found\n",line_count,yytext);
		}

"return"	{
			fprintf(tokenout,"<RETURN>");
			fprintf(logout,"Line no %d: TOKEN <RETURN> Lexeme %s found\n",line_count,yytext);
		}

"switch"	{
			fprintf(tokenout,"<SWITCH>");
			fprintf(logout,"Line no %d: TOKEN <SWITCH> Lexeme %s found\n",line_count,yytext);
		}

"case"	{
			fprintf(tokenout,"<CASE>");
			fprintf(logout,"Line no %d: TOKEN <CASE> Lexeme %s found\n",line_count,yytext);
		}

"default"	{
			fprintf(tokenout,"<DEFAULT>");
			fprintf(logout,"Line no %d: TOKEN <DEFAULT> Lexeme %s found\n",line_count,yytext);
		}

"continue"	{
			fprintf(tokenout,"<CONTINUE>");
			fprintf(logout,"Line no %d: TOKEN <CONTINUE> Lexeme %s found\n",line_count,yytext);
		}


"+"|"-"	{	//keyword completes here
	fprintf(tokenout,"<ADDOP,%s>",yytext);
	fprintf(logout,"Line no %d: TOKEN <ADDOP> Lexeme %s found\n",line_count,yytext);
    string type = "ADDOP" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    bool v=st.insertion(t);
    //printf("%d",v);
    if(v)
    {
        st.printFile();   
    }
    else
    {
        fprintf(logout,"already exist\n");
    }        
}

"*"|"/"|"%"	{
	fprintf(tokenout,"<MULOP,%s>",yytext);
	fprintf(logout,"Line no %d: TOKEN <MULOP> Lexeme %s found\n",line_count,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	// There is a '|' in "+"'s rule, this means match execute the action for following rule
    string type = "MULOP" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    bool v=st.insertion(t);
    //printf("%d",v);
    if(v)
    {
        st.printFile();   
    }
    else
    {
        fprintf(logout,"already exist\n");
    }  
}

"++"|"--" {
	fprintf(tokenout,"<INCOP,%s>",yytext);
	fprintf(logout,"Line no %d: TOKEN <INCOP> Lexeme %s found\n",line_count,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	// There is a '|' in "+"'s rule, this means match execute the action for following rule
    string type = "INCOP" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    bool v=st.insertion(t);
    //printf("%d",v);
    if(v)
    {
        st.printFile();   
    }
    else
    {
        fprintf(logout,"already exist\n");
    }  
}

"<"|"<="|">"|">="|"=="|"!=" {
	fprintf(tokenout,"<RELOP,%s>",yytext);
	fprintf(logout,"Line no %d: TOKEN <RELOP> Lexeme %s found\n",line_count,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	// There is a '|' in "+"'s rule, this means match execute the action for following rule
    string type = "RELOP" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    bool v=st.insertion(t);
    //printf("%d",v);
    if(v)
    {
        st.printFile();   
    }
    else
    {
        fprintf(logout,"already exist\n");
    }  
}

"="	{
	fprintf(tokenout,"<ASSIGNOP,%s>",yytext);
	fprintf(logout,"Line no %d: TOKEN <ASSIGNOP> Lexeme %s found\n",line_count,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	// There is a '|' in "+"'s rule, this means match execute the action for following rule
    string type = "ASSIGNOP" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    bool v=st.insertion(t);
    //printf("%d",v);
    if(v)
    {
        st.printFile();   
    }
    else
    {
        fprintf(logout,"already exist\n");
    }  
}

"&&"|"||" {
	fprintf(tokenout,"<LOGICOP,%s>",yytext);
	fprintf(logout,"Line no %d: TOKEN <LOGICOP> Lexeme %s found\n",line_count,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	// There is a '|' in "+"'s rule, this means match execute the action for following rule
    string type = "LOGICOP" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    bool v=st.insertion(t);
    //printf("%d",v);
    if(v)
    {
        st.printFile();   
    }
    else
    {
        fprintf(logout,"already exist\n");
    }  
}

"&"|"|"|"<<"|">>" {
	fprintf(tokenout,"<BITOP,%s>",yytext);
	fprintf(logout,"Line no %d: TOKEN <BITOP> Lexeme %s found\n",line_count,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	// There is a '|' in "+"'s rule, this means match execute the action for following rule
    string type = "BITOP" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    bool v=st.insertion(t);
    //printf("%d",v);
    if(v)
    {
        st.printFile();   
    }
    else
    {
        fprintf(logout,"already exist\n");
    }  
}

"!"	{
	fprintf(tokenout,"<NOT,%s>",yytext);
	fprintf(logout,"Line no %d: TOKEN <NOT> Lexeme %s found\n",line_count,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	// There is a '|' in "+"'s rule, this means match execute the action for following rule
    string type = "NOT" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    bool v=st.insertion(t);
    //printf("%d",v);
    if(v)
    {
        st.printFile();   
    }
    else
    {
        fprintf(logout,"already exist\n");
    }  
}

"("	{
	fprintf(tokenout,"<LPAREN,%s>",yytext);
	fprintf(logout,"Line no %d: TOKEN <LPAREN> Lexeme %s found\n",line_count,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	// There is a '|' in "+"'s rule, this means match execute the action for following rule
    string type = "LPAREN" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    bool v=st.insertion(t);
    //printf("%d",v);
    if(v)
    {
        st.printFile();   
    }
    else
    {
        fprintf(logout,"already exist\n");
    }  
}

")"	{
	fprintf(tokenout,"<RPAREN,%s>",yytext);
	fprintf(logout,"Line no %d: TOKEN <RPAREN> Lexeme %s found\n",line_count,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	// There is a '|' in "+"'s rule, this means match execute the action for following rule
    string type = "RPAREN" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    bool v=st.insertion(t);
    //printf("%d",v);
    if(v)
    {
        st.printFile();   
    }
    else
    {
        fprintf(logout,"already exist\n");
    }  
}

"{" {
	fprintf(tokenout,"<LCURL,%s>",yytext);
	fprintf(logout,"Line no %d: TOKEN <LCURL> Lexeme %s found\n",line_count,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	// There is a '|' in "+"'s rule, this means match execute the action for following rule
    string type = "LCURL" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    bool v=st.insertion(t);
    //printf("%d",v);
    if(v)
    {
        st.printFile();   
    }
    else
    {
        fprintf(logout,"already exist\n");
    }  
}

"}"	{
	fprintf(tokenout,"<RCURL,%s>",yytext);
	fprintf(logout,"Line no %d: TOKEN <RCURL> Lexeme %s found\n",line_count,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	// There is a '|' in "+"'s rule, this means match execute the action for following rule
    string type = "RCURL" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    bool v=st.insertion(t);
    //printf("%d",v);
    if(v)
    {
        st.printFile();   
    }
    else
    {
        fprintf(logout,"already exist\n");
    }  
}

"["	{
	fprintf(tokenout,"<LTHIRD,%s>",yytext);
	fprintf(logout,"Line no %d: TOKEN <LTHIRD> Lexeme %s found\n",line_count,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	// There is a '|' in "+"'s rule, this means match execute the action for following rule
    string type = "LTHIRD" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    bool v=st.insertion(t);
    //printf("%d",v);
    if(v)
    {
        st.printFile();   
    }
    else
    {
        fprintf(logout,"already exist\n");
    }  
}

"]"	{
	fprintf(tokenout,"<RTHIRD,%s>",yytext);
	fprintf(logout,"Line no %d: TOKEN <RTHIRD> Lexeme %s found\n",line_count,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	// There is a '|' in "+"'s rule, this means match execute the action for following rule
    string type = "RTHIRD" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    bool v=st.insertion(t);
    //printf("%d",v);
    if(v)
    {
        st.printFile();   
    }
    else
    {
        fprintf(logout,"already exist\n");
    }  
}

","	{
	fprintf(tokenout,"<COMMA,%s>",yytext);
	fprintf(logout,"Line no %d: TOKEN <COMMA> Lexeme %s found\n",line_count,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	// There is a '|' in "+"'s rule, this means match execute the action for following rule
    string type = "COMMA" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    bool v=st.insertion(t);
    //printf("%d",v);
    if(v)
    {
        st.printFile();   
    }
    else
    {
        fprintf(logout,"already exist\n");
    }  
}

";"	{
	fprintf(tokenout,"<SEMICOLON,%s>",yytext);
	fprintf(logout,"Line no %d: TOKEN <SEMICOLON> Lexeme %s found\n",line_count,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	// There is a '|' in "+"'s rule, this means match execute the action for following rule
    string type = "SEMICOLON" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    bool v=st.insertion(t);
    //printf("%d",v);
    if(v)
    {
        st.printFile();   
    }
    else
    {
        fprintf(logout,"already exist\n");
    }  
}




[a-zA-Z_][a-zA-Z0-9_]*  {

    //identifier code
    fprintf(tokenout,"<ID,%s>",yytext);
    fprintf(logout,"Line no %d: TOKEN <ID> Lexeme %s found\n",line_count,yytext);
    //symboltable code

    string type = "ID" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    bool v=st.insertion(t);
    //printf("%d",v);
    if(v)
    {
        st.printFile();   
    }
    else
    {
        fprintf(logout,"already exist\n");
    }


}

{IC}[\\]{IC}|{IC}([^'\r\n\t\f\v])* {
    fprintf(logout,"Line no %d: Unfinished character error %s\n",line_count,yytext);
    errorCount++;
}

{IC}.{IC} {   

	char s = yytext[1];
	fprintf(tokenout,"<CONST_CHAR,%c>",s);
	fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %c found\n",line_count,s);
	//insert in symbol table and print symbol table content(only non empty buckets)
	//SymbolInfo *si=new SymbolInfo(string(yytext),"CONST_INT");
	//st.insert(si);
    char *k = new char[2];
    k[0]=yytext[1];
    k[1]='\0';
    string type = "CONST_CHAR" ;
    string name(k);
    SymbolInfo *t = new SymbolInfo(name,type);
    bool v=st.insertion(t);
    //printf("%d",v);
    if(v)
    {
        st.printFile();   
    }
    else
    {
        fprintf(logout,"already exist\n");
    }
}

















({DIGIT}*\.{DIGIT}+)(E[-+]?[0-9]+)?|{DIGIT}+(E[-+]?[0-9]+)  {
	fprintf(tokenout,"<CONST_FLOAT,%s>",yytext);
	fprintf(logout,"Line no %d: TOKEN <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	//SymbolInfo *si=new SymbolInfo(string(yytext),"CONST_INT");
	//st.insert(si);
    string type = "CONST_FLOAT" ;
    //string type = "CONST_INT" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    bool v=st.insertion(t);
    //printf("%d",v);
    if(v)
    {
        st.printFile();   
    }
    else
    {
        fprintf(logout,"already exist\n");
    }
}

({DIGIT}*\.{DIGIT}*\.).* {
    fprintf(logout,"Line no %d: Too many decimal point error %s\n",line_count,yytext);
    errorCount++;
}

({DIGIT}*\.{DIGIT}+)(E[-+]?{FLOAT})?|{DIGIT}+(E[-+]?{FLOAT}) {
    fprintf(logout,"Line no %d: Ill formed number error %s\n",line_count,yytext);
    errorCount++;
}

{DIGIT}+{ID} {
    fprintf(logout,"Line no %d: Invalid Suffix on numeric constant or invalid prefix on identifier for character sequence %s\n",line_count,yytext);
    errorCount++;
}

{IC}[^\\\n\r][^\n\r]+{IC} {
    //printf("1%s\n",yytext);
    /*int len = strlen(yytext);
    for(int i=0;i<len;i++)
    {
        printf("%c %d\n",yytext[i],yytext[i]);
    }*/

    fprintf(logout,"Line no %d: Multi character constant error %s\n",line_count,yytext);
    errorCount++;
}

{IC}[\\][^'\r\n\t\f\v][^'\r\n\t\f\v]+{IC} {
   // printf("2%s\n",yytext);

    fprintf(logout,"Line no %d: Multi character constant error %s\n",line_count,yytext);
    errorCount++;
}

{IC}[\\][^\\ntafrbv0']{IC} {
    //printf("3%s\n",yytext);

    fprintf(logout,"Line no %d: Multi character constant error %s\n",line_count,yytext);
    errorCount++;
}














{DIGIT}+ {  
	fprintf(tokenout,"<CONST_INT,%s>",yytext);
	fprintf(logout,"Line no %d: TOKEN <CONST_INT> Lexeme %s found\n",line_count,yytext);
	//insert in symbol table and print symbol table content(only non empty buckets)
	//SymbolInfo *si=new SymbolInfo(string(yytext),"CONST_INT");
	//st.insert(si);
    //string type = "CONST_FLOAT" ;
    string type = "CONST_INT" ;
    string name(yytext);
    SymbolInfo *t = new SymbolInfo(name,type);
    bool v=st.insertion(t);
    //printf("%d",v);
    if(v)
    {
        st.printFile();   
    }
    else
    {
        fprintf(logout,"already exist\n");
    }
    
}

. {
    fprintf(logout,"Line no %d: Unrecognized charecter %s\n",line_count,yytext);
}

<<EOF>> {
    fprintf(logout,"Total error %d\n",errorCount);
    fprintf(logout,"Total line %d\n",line_count);
    st.printFile();
    return 0;
}







%%

int main(int argc,char *argv[]){

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
	//st.print();
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}

