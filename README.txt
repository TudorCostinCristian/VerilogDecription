Nume: Tudor Costin-Cristian
Grupa: 334AB

Modulul decryption_regfile
Pentru imprementarea modulului decryption_regfile, am folosit blocul always @(posedge clk) pentru a realiza pe frontul crescator al semnalului de ceas, in ordine, 
urmatoarele verificari/operatii:
- Am verificat daca semnalul de reset este 0, caz in care am atribuit fiecarui output valoarea de reset precizata in enuntul temei(convertita in decimal).
- Semnalele done si error pot fi 1 doar in cazul in care acestea au fost ridicate de o citire/scriere in urma cu un ciclu de ceas, ceea ce inseamna ca trebuie sa
le setam inapoi la 0. Asadar, am verificat daca aceste semnale sunt 1 si le-am setat pe 0.
- Am verificat daca semnalul write a fost setat pe 1, am validat adresa si am atribuit valoarea din wdata registrului corespunzator. Daca adresa
nu corespunde unui registru, se va seta pe 1 semnalul error. Apoi am setat pe 1 semnalul done pentru a marca incheierea tranzactiei. 
- Am verificat daca semnalul read a fost setat pe 1, am validat adresa, apoi am copiat in rdata registrul corespunzator. In cazul in care adresa
nu corespunde unui registru, se va seta pe 1 semnalul error. De asemenea, am setat pe 1 semnalul done.

Modulul caesar_decryption
Pentru modulul caesar_decryption, am folosit blocul always @(posedge clk) pentru a verifica valoarea input-ului valid_i. In cazul in care valid_i este 1, voi
copia in data_o valoarea data de scaderea lui key din data_i si voi seta valid_o pe 1. Altfel, daca valid_i este 0, voi seta valid_o pe 0.

Modulul scytale_decryption
Pe frontul crescator al semnalului de ceas, verific daca valid_i este 1 si busy este 0 pentru a face citirea. In cazul in care caracterul citit este
diferit de START_DECRYPTION_TOKEN, adaug valoarea din data_i in registrul charlist pe pozitia curenta si cresc contorul nr_chars(pentru numarul de caractere citite)
cu 1. Daca valoarea citita este START_DECRYPTION_TOKEN, ridic semnalul busy si resetez registrele folosite pentru decriptare.
Tot pe frontul crescator al semnalului de ceas, verific daca busy este 1. Daca registrul startL(folosit pentru memorarea liniei pe care ma aflu in decriptare) este mai
mic decat key_N, inseamna ca inca nu am copiat toate elementele din charlist in data_o. Asadar, voi copia valoarea din charlist aflata la pozitia key_N*startC + startL
in data_o si voi incrementa registrele startL si startC, dupa caz. In cazul in care startL este egal cu key_N, inseamna ca am depasit ultima linie, asa ca voi reseta semnalele de
iesire si registrele charlist si nr_chars.

Modulul zigzag_decryption + BONUS
Citirea caracterelor si salvarea acestora in registrul charlist se face la fel ca in cazul decriptarii scytale.
Pe frontul crescator al semnalului de ceas, pentru decriptare, in cazul in care nu am gasit inca toate caracterele din textul decriptat iar semnalul busy este 1,
am folosit niste registrii pentru a memora si actualiza pozitia din charlist(pos), pozitia in fiecare linie(linePos), linia pe care ma aflu(line) si
directia in care trebuie sa merg pentru urmatoarea linie. Daca am ajuns la linia 0(cea mai de sus), voi trece la linia 1 si voi seta directia in jos(dir = 0). 
Daca am ajuns la linia key-1, voi trece la linia key-2 si voi seta directia in sus(dir = 1). Actualizand aceste registre pe fiecare front crescator al semnalului clk
pe tot parcursul decriptarii, inseamna ca tot ce trebuie sa fac este sa copiez in data_o valoarea din charlist de la pozitia (lineStart[line*8 +: 8] + linePos[line*8 +: 8])*8 +: 8,
unde linePos si line sunt pozitiile explicate mai sus, iar lineStart reprezinta un registru in care memorez pozitia in care incepe fiecare dintre cele key linii
in registrul charlist.
Pentru a seta pozitiile de inceput(lineStart) pentru fiecare linie, am verificat in blocul always @(*) daca valid_i este 1 si busy este 0, iar caracterul din data_i
este START_DECRYPTION_TOKEN. In acest caz, voi calcula dimensiunea fiecarei linii si o voi folosi pentru a stabili pozitia de inceput a liniei urmatoare.
Deoarece linia 0 incepe la pozitia 0, este suficient sa adun dimensiunea si pozitia de inceput ale liniei anterioare pentru a afla pozitia de inceput a liniei curente.
Pentru a stabili dimensiunile liniilor, am observat ca atunci cand parcurgem caracterele in zig-zag pe linii se formeaza un ciclu:
[L(0), L(1), .. , L(key-1), L(key-2), .. , L(2), L(1)], [L(0), L(1), .. , L(key-1), L(key-2), .. , L(2), L(1)] ....
Am determinat faptul ca intr-un astfel de ciclu sunt parcurse 2*(key - 1) caractere si am notat aceasta valoarea cu "restart". De asemenea, am observat ca intr-un ciclu
este parcurs cate 1 caracter de pe liniile L(0) si L(key-1), respectiv cate doua caractere de pe liniile din mijloc. Am adaptat codul din modulul division de la Tema1
pentru a imparti numarul total de caractere din text la valoarea "restart" si am aflat dimensiunile liniilor intr-un for de la 0 la 4(deoarece pot avea cheia maxima 5, 
deci cea mai mare linie va fi 4), in care voi calcula valorile necesare doar in cazul in care linia curenta i este mai mica decat cheia de decriptare. In cazul in care
ultimul ciclu nu contine suficiente caractere pentru a fi finalizat, am folosit restul aceleiasi impartiri pentru a determina daca trebuie sa cresc dimensiunea unei linii cu 0, 1 sau 2.

Modulul DEMUX
Pe frontul crescator al semnalului clk_mst, am copiat valoarea lui data_i intr-un registru data_i_reg si am setat valoarea registrului start_clk_sys pe 1. Voi folosi acest registru 
pentru a porni contorul cnt_sys pentru frontul crescator al semnalului clk_sys imediat dupa primul front crescator al semnalului clk_mst. Am reusit astfel sa sincronizez valoarea
0 a contorului cnt_sys cu frontul crescator al semnalului clk_mst. 
Am folosit un contor cnt_start pentru a astepta 3 cicluri clk_sys din momentul in care primesc niste valori pe posedge clk_sys pana in momentul in care le scriu pe semnalele de output, 
si un contor cnt_stop pentru a astepta 3 cicluri din momentul in care valid_i devine 0 pana in momentul in care opresc copierea valorilor din registre pe output.
Avand aceste valori, pe frontul crescator al semnalului clk_sys, in cazul in care cnt_start < 3 iar valid_i este 1, voi creste contorul cnt_start si voi pregati
contorul pentru oprirea copierii datelor setandu-l pe 3.
Daca valid_i este 0 iar cnt_start este diferit de 0, inseamna ca nu am terminat de pus toate valorile pe output si scad contorul pentru oprirea copierii datelor. 
In cazul in care cnt_start = 3, iar cnt_sys = 0, inseamna ca datele din data_i sunt valide, adica ma aflu in dreptul posedge clk_mst, asa ca folosesc select
pentru a pune pe output valoarea din data_i. Daca datele din data_i nu sunt valide(adica cnt_sys > 0), voi folosi datele salvate in registrul data_i_reg
pentru a le copia in semnalele de output in functie de select.
In momentul in care cnt_stop este 0 pe frontul crescator al semnalului cnt_sys, inseamna ca am ajuns la finalul copierii datelor, asa ca setez semnalele de output pe 0 si 
resetez contorul de start.

Modulul MUX
Pe frontul crescator al semnalului clk, setez valid_o pe 0 si, in functie de valoarea lui select, verific valoarea valid_i corespunzatoare si pun pe output semnalele decriptarii respective,
ridicand de asemenea semnalul valid_o.

Modulul decryption_top
In modului decryption top, am declarat variabilele wire necesare pentru a face conexiunile si m-am folosit apoi de toate modulele implementate pentru a obtine semnalele de output.
Pentru a determina valoarea lui busy, am folosit operatia OR intre toate semnalele busy ale modulelor de decriptare.