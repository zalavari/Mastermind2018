-module(mmind).
-author('zalavarm@gmail.com').
-vsn('2018-11-16').
-export([mmind/2]).
%-compile(export_all).

-type code()   :: [integer()].         %% A code() típus egy integer() típusú elemekből álló lista típusa
-type blacks() :: integer().           %% A blacks() típus azonos az integer() típussal
-type whites() :: integer().           %% A whitess() típus azonos az integer() típussal
-type answer() :: {blacks(),whites()}. %% Az answer() típusú érték egy olyan pár, amelynek első eleme blacks(), második eleme whites() típusú.
-type hint()   :: {code(),answer()}.   %% A hint() típusú érték egy olyan pár, amelynek első eleme code(), második eleme answer() típusú.
-type myhint()   :: {code(),zsak_alak(),answer()}.

-type zsak_alak() :: [zsak_elem()].
-type zsak_elem() :: {any(),integer()}.

%A "főprogram", előfeldolgozást végez, meghívja az mmm-t, amely előállítja a megoldást
-spec mmind:mmind(Max::integer(), Hints::[hint()]) -> Codes::[code()].
mmind(Max, HintList) ->
	{Tipps,Answers}=lists:unzip(HintList),
	TippsZsak=listak_zsakok(Tipps),
	[Tipp|_]=Tipps,
	L=length(Tipp),
	MyHintList=lists:zip3(Tipps,TippsZsak,Answers),
	mmm(Max,MyHintList,L).

%meghatározza azon lehetséges kódértékeket, amelyek megfelelnek a feltételeknek. (Súgás lista tartalma)
-spec mmind:mmm(Max::integer(), Hints::[myhint()], L::integer()) -> Codes::[code()].
mmm(_Max,_HintList, 0) -> [[]];
mmm(Max,HintList,L) ->
[
	[CodeHead|CodeTail]
	||
	CodeHead <- lists:seq(1,Max),
	CodeTail <-
	try
		mmm(Max,simplifyHintList(CodeHead,HintList,L-1),L-1)
	catch
		throw:error -> []
	end
].

%A súgáslista (HintList) egyszerűsítettje az új súgás (NewHintList) lista
%az egyszerűsítést úgy végezzük, hogy feltesszük, hogy a kódban az első helyen TippHead szám áll
%Az L szám megadja, hogy még milyen hosszúnak kell lennie a kódnak 
%(Az első elemet nem számolva.) Ezt csak a keresési tér szűkítésénél használjuk.
%Amennyiben valamilyen okból tudhatjuk, hogy nem lesz egy kód sem, 
%ami TippHead-dal kezdődik, error hiba dobódhat.
-spec mmind:simplifyHintList(CodeHead::integer(), HintList::[myhint()], L::integer()) -> NewHintList::[myhint()].
simplifyHintList(_CodeHead,[],_L) -> [];
simplifyHintList(CodeHead,HintList,L) ->
		[Hint|HintListTail]=HintList,
		NewHint=simplifyHint(CodeHead,Hint,L),
		NewHintListTail=simplifyHintList(CodeHead,HintListTail,L),
		[NewHint|NewHintListTail].

%simplifyHint(TippHead,Hint,L)->NewHintList
%A súgás (Hint) egyszerűsítettje az új súgás (NewHint)
%az egyszerűsítést úgy végezzük, hogy feltesszük, hogy a kódban az első helyen TippHead szám áll
%részletesebben a dokumentációban
-spec mmind:simplifyHint(CodeHead::integer(), Hint::myhint(), L::integer()) -> NewHint::myhint().
simplifyHint(CodeHead,{[TippHead|TippTail],TippZsak,{Black,White}},L) ->
	NewTippZsak=remove_from_zsak(CodeHead,TippZsak),
	case (CodeHead=:=TippHead) of
	true->
		case NewTippZsak=:=not_found of
		false->
			case (Black-1 >= 0 andalso Black-1+White >= 0) of
			true -> {TippTail, NewTippZsak, {Black-1,White}};
			false -> throw(error)
			end;
		true->
			case ((Black-1) >= 0 andalso (Black+White) =<L) of 
			true -> {TippTail, TippZsak, {Black-1,White+1}};
			false -> throw(error)
			end
		end;
	false->
		case NewTippZsak=:=not_found of
		false->
			case (Black =< L andalso Black+White-1 >= 0) of
			true -> {TippTail, NewTippZsak, {Black,White-1}};
			false -> throw(error)
			end;
		true->
			case (Black =< L  andalso Black+White =< L) of
			true -> {TippTail, TippZsak, {Black,White}};
			false -> throw(error)
			end
				
		end
	end.
	
%Az E elemet kivéve ZS1 zsák-alakú listából, a visszamaradt zsák ZS2.
%Amennyiben az E elem nincs benne a listában not_found értéket kapunk
remove_from_zsak(_Elem, []) -> not_found;
remove_from_zsak(Elem, [{Elem,1}|ZsakT]) -> ZsakT;
remove_from_zsak(Elem, [{Elem,A}|ZsakT]) -> [{Elem,A-1}|ZsakT];
remove_from_zsak(Elem, [{ZsElem,_A}|ZsakT]) -> 
	NewZsakT=remove_from_zsak(Elem,ZsakT),
	case NewZsakT=:=not_found of
	true -> not_found;
	false -> [{ZsElem,_A}|NewZsakT]
	end.
	
%Innét az első kisházi másolata jön.
	
%A listák listáját Zsák-alakú listák listájává alakítja
listak_zsakok([]) -> [];
listak_zsakok([Lista|ListakT]) -> [lista_zsak(Lista)|listak_zsakok(ListakT)].

%listát zsák-alakú listává alakít
lista_zsak(L) -> lista_zsak_zsak(L,[]).

%listát zsák-alakú listává alakít, és azt hozzáadja a paraméterül kapott másik zsák alakú listához
lista_zsak_zsak([],ZS) -> ZS;
lista_zsak_zsak([H|T],Temp) -> 	
	lista_zsak_zsak(T,put_zsak(H,Temp)).

%Zsák alakú listába beszúr egy elemet
put_zsak(Elem, []) -> [{Elem,1}];
put_zsak(Elem, [{Elem,A}|T]) -> [{Elem,A+1}|T];
put_zsak(Elem, [H|T]) -> T2=put_zsak(Elem,T),[H|T2].