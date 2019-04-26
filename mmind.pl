
%:- use_module(library(lists)).

%mmind(Max, HintList, Code) A "főprogram", előfeldolgozást végez, meghívja az mmm segédpredikátumot, amely előállítja a megoldást
mmind(Max,HintList, Code) :-
	[HintListHead-_/_|_]=HintList,
	length(HintListHead,L),
	addZsak(HintList,MyHintList),
	mmm(Max,MyHintList,Code,L).

%meghatározza azon lehetséges kódértékeket, amelyek megfelelnek a feltételeknek. (Súgás lista tartalma)
mmm(_Max, _HintList, [], 0) :- !.
mmm(Max, HintList, [CodeHead|CodeTail], L) :-
	max(CodeHead,Max),	
	L1 is L-1, 
	simplifyHintList(CodeHead,HintList, NewHList, L1),
	%write(L : CodeHead), write('    '),
	mmm(Max,NewHList,CodeTail, L1).

%max(Number,Max): 0<Number<=Max, -,+ módban használjuk, ekkor Number felveszi az 1 és a Max közötti értékeket
%ellenőrzést nem végzünk, elvárjuk, hogy Max pozitív egész.
max(Max,Max).
max(Number,Max) :- Max>1, Max2 is Max-1, max(Number,Max2).

%simplifyHintList(CodeHead,HintList,NewHintList,L)
%A súgáslista (HintList) egyszerűsítettje az új súgás (NewHintList) lista
%az egyszerűsítést úgy végezzük, hogy feltesszük, hogy a kódban az első helyen CodeHead szám áll
%Az L szám megadja, hogy még milyen hosszúnak kell lennie a kódnak 
%(Az első elemet nem számolva.) Ezt csak a keresési tér szűkítésénél használjuk.
%Amennyiben valamilyen okból tudhatjuk, hogy nem lesz egy kód sem, 
%ami CodeHead-dal kezdődik, a predikátum meghiúsulhat.
simplifyHintList(_CodeHead,[],[],_L) :- !.
simplifyHintList(CodeHead,[HintListHead|HintListTail],[NewHintListHead|NewHintListTail],L) :-
	simplifyHint(CodeHead,HintListHead,NewHintListHead,L),
	simplifyHintList(CodeHead,HintListTail,NewHintListTail,L).

%simplifyHint(TippHead,Hint,NewHint,L)
%A súgás (Hint) egyszerűsítettje az új súgás (NewHint)
%az egyszerűsítést úgy végezzük, hogy feltesszük, hogy a kódban az első helyen TippHead szám áll
%részletesen a dokumentációban
simplifyHint(CodeHead,[TippHead|TippTail]-TippZsak-Black/White,TippTail-NewTippZsak-NewBlack/NewWhite,L) :-
	CodeHead = TippHead ->
    (   
		select(CodeHead,TippZsak,NewTippZsak) ->
			NewBlack is Black-1,
			NewBlack >= 0,
			NewWhite = White,			
			NewBlack+NewWhite >= 0
		;
			NewBlack is Black-1,
			NewBlack >= 0,
			NewWhite is White+1,
			NewWhite+NewBlack =< L,
        	NewTippZsak=TippZsak
	)
	;
    (   
		select(CodeHead,TippZsak,NewTippZsak) ->
			NewBlack = Black,			
			NewBlack =< L,
			NewWhite is White-1,
			NewBlack+NewWhite >= 0
		;
			NewBlack = Black,
			NewBlack =< L,			
			NewWhite = White,
			NewWhite+NewBlack =< L,
        	NewTippZsak=TippZsak
    ).

%addZsak(HintList,MyHintList)
%A HintList sugásai egy, a kódokból előállított multihalmazokkal kiegészített súgásoknak a listája a MyHintList
%Tehát a HintList egy eleme Tipp-Black/White, akkor a MyHintList hozzá tartozó eleme Tipp-CodeZsak-Black/White felépítésű,
%Ahol az azonos változók azonos értéket jelölnek, CodeZsak pedig a Tipp elemeiből képzett multihalmaz
addZsak([],[]).
addZsak([Tipp-Black/White|HintListTail],[Tipp-Tipp-Black/White|NewHintListTail]) :- 
	addZsak(HintListTail,NewHintListTail).
    