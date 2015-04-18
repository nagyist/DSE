function [P, idx, dist, vertices_tin, calidad_tin, planos]=preparaTIN_v05(P, npb, tolerancia)
%% Funci�n que prepara los puntos y genera los planos objeto de estudio
% Adri�n Riquelme, abril 2013
% Input: - P. matriz de nx3 que contiene las coordenadas de los puntos
% V04: el test de coplanaridad s�lo admite aquellos que sean coplanares,
% los que no los eliminar�
% Output: 
% P2: matrix de puntos que tienen coplanares
% - idx: matriz [n,npb+1]. La primera columna indica el punto de
% referencia, las npb columnas restantes indican los npb puntos m�s
% cercanos seg�n la norma elegida. El valor es el id del punto.
% - dist: matriz [n,npb+1]. La primera columna ser�a cero, pues es la
% distancia de un punto consigo mismo. Las npb columnas siguientes indican
% la distancia el punto de referencia con el punto
% - vertices_tin: matriz que indica los puntos que forman parte del plano
% - calidad_tin: indica el n de puntos que forman cada plano
% - planos: matriz que contiene la ecuaci�n de cada plano, ABCD

% cargamos los puntos en una matriz de np x 3
% P = load ('puntos.txt');
[np,~] = size ( P );
% np es el num total de puntos disponibles se comprueba que toda la tabla
% est� compuesta por nums y que el n de columnas es de 3 la f isnan
% devuelve 1 si no es n o 0 en caso de que lo sea. Si al final el
% test es de validaci�n es 0 ser� porque todos los valores de la matriz
% son n�meros. En caso de que no lo sea, el test de validaci�n nos
% dir� cuantos valores no num�ricos hay.


%% buscamos los puntos cercanos con knnsearch
% primero definimos una matriz con las coordenadas de puntos en las columnas:
% col 1: coordenada x
% col 2: coordenada y
% col 3: coordenada z
% Para ello, hay que quitar la primera columna que es el id de cada punto

P=P(:,1:3);

% Ahora con el knnsearch hay que buscar para cada punto, cuales son los mas
% cercanos y cual es esa distancia. La norma a utilizar es la norma
% euclidea (minkowski p=2) npb (n de puntos en el buffer) indica
% cuantos puntos busca, por lo que como el primer punto mas cercano
% es �l mismo, k es npb+1
% npb = input('Indique el num de puntos cercanos a buscar: (num sugerido 8)  ');
if npb<4
    msgbox('Has elegido un n�mero de puntos insuficiente. Se fija en 4','atenci�n!!','warn');
    npb = 4;
end
% como la primera columna es el mismo punto, aumentamos el n de puntos de b�squeda en 1
% npb = npb +1;

[idx,dist]=knnsearch(P,P,'NSMethod','kdtree','distance','euclidean','k',npb);
% idx: matriz [n,npb+1]. La primera columna indica el punto de referencia,
% las npb columnas restantes indican los npb puntos m�s cercanos seg�n
% la norma elegida. El valor es el id del punto. dist: matriz [n,npb+1]. La
% primera columna es cero, pues es la distancia de un punto consigo
% mismo. Las npb columnas siguientes indican la distancia el punto de
% referencia con el punto


%% b�squeda de coplanares
% Buscamos la coplanaridad de los puntos encontrados
% La salida es una matriz de dim [np k+1]. En primer lugar, la
% creamos con una matriz de ceros.
vertices_tin = zeros (np, npb+1);    
vertices_tin2 = zeros (np, npb+1);
planos = zeros (np, 3);
calidad_tin=zeros(np,1);
% para iniciar la b�squeda, necesitamos definir una tolerancia de
% coplanaridad. �sta es el % que supone landa3 sobre el total de los
% valores propios
if tolerancia >0 
else
    msgbox('La tolerancia introducida no es v�lida. Se fija por defecto a 0,01,','Atensi�n!!!!!','warn');
    tolerancia=0.01;
end

% hay que recorrer desde 1 hasta np los puntos de b�squeda
% creamos un vector calidad_tin que nos indica la cantidad de puntos con
% los que se crea un plano asociado a un punto de referencia

P2=zeros(size(P)); % inicio la nube de puntos coplanares, al final eliminar� los que no lo son
np2=1; % n�mero de puntos coplanares encontrados
nnoise=1; %iniciamos el n�mero de ru�dos encontrados
h=waitbar(0,'Calculating coplanar planes. Please wait');
for j=1:np
    %primero, chequeamos si todos los puntos cercanos son coplanares. Si lo
    %son, los aceptamos todos y saltamos al siguiente punto de referencia.
    %En caso contrario, buscaremos cual descartar.
    % montamos en la matriz con los puntos
    %idx era una matriz con los indexs de puntos cercanos. El n max de
    %columnas es de npb, cuando un punto no es cercano, rellena con ceros.
    V=find(idx(j,:)>0); %index of the near points
    test_tin=P(idx(j,V),1:3); %points to test coplanarity
    [pc, ~, valor_propio] = princomp (test_tin,'econ');
    [n,~]=size(valor_propio);
    if n==3
        %desviacion=((valor_propio(3,1)^2/norm(valor_propio,2)^2))^0.5;
        %l1=abs(valor_propio(1,1));
        %l2=abs(valor_propio(2,1));
        %l3=abs(valor_propio(3,1));
        desviacion=abs(valor_propio(3,1))/(abs(valor_propio(1,1))+abs(valor_propio(2,1))+abs(valor_propio(3,1)));
    else
        desviacion=0;
    end
    if desviacion <= tolerancia
        copl = 1;
    else
        copl = 0;
    end
    if copl == 1
        % como es coplanar, paso el punto y su calidad
        P2(np2,:)=P(j,:); % guardamos el punto en P2
        vertices_tin(np2,1:length(V))=idx(j,V);
        vn=cross(pc(:,1),pc(:,2));% vector normal
        planos(np2,:)=vn;
        calidad_tin(np2,1)=length(V);
        np2=np2+1; % incrementamos el contador de coplanares
    end
    % waitbar(j/np,h,sprintf('Point %d de %d', j, np));
    waitbar(j/np,h);
end
% limpiamos la matriz de salida P2
np2=np2-1;
if np2==0
    msgbox('Atention!! No coplanar poin was founded!!!');
else
    P=P2(1:np2,:); % actualizamos P2
    vertices_tin=vertices_tin(1:np2,:); %actualizamos vertices_tin2
    planos=planos(1:np2,:); %actualizamos la salida planos
    calidad_tin=calidad_tin(1:np2,1);
end
close(h); %cerramos la ventana de avance
end
    