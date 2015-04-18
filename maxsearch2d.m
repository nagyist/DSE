function [ dmax, Xmax, Ymax ] = maxsearch2d( X,Y,density,tolerancia)
% maxsearch2d, Adri�n Riquelme, abril 2013
%   Funci�n que busca los m�ximos locales en una superficie no param�trica,
%   definida por los valores de la funci�n.
%   Busca para cada valor si es el m�ximo entre sus vecinos.
% Input:
% - X: coordenadas x de los valores. Matriz nxn
% - Y: coordenadas y de los valores. Matriz nxn
% - density: valores de la superficie. Matriz nxn
% - tolerancia: % valor m�nimo a de density para buscar el m�ximo, tanto
% por uno de la densidad m�xima
% Output:
% - dmax: vector con los valores m�ximos encontrados
% - Xmax: vector con las coordenadas x de los valores m�ximos
% - Ymax: vector con las coordenadas y de los valores m�ximos

% determinamos el valor total de la suma de valores de density
densidadmaxima=max(max(density,[],1),[],2);
dminima=densidadmaxima*tolerancia;
Xmax=[]; %iniciamos los vectores resultado
Ymax=[];
dmax=[];
[n,n]=size(density);
for ii=2:n-1
    for jj=2:n-1
        if density(ii,jj)>=dminima && ...
                density(ii,jj)>density(ii-1,jj-1) && ...
                density(ii,jj)>density(ii-1,jj) && ...
                density(ii,jj)>density(ii-1,jj+1) && ...
                density(ii,jj)>density(ii,jj-1) && ...
                density(ii,jj)>density(ii,jj+1) && ...
                density(ii,jj)>density(ii+1,jj-1) && ...
                density(ii,jj)>density(ii+1,jj) && ...
                density(ii,jj)>density(ii+1,jj+1)
            dmax=[dmax density(ii,jj)];
            Xmax=[Xmax X(ii,jj)];
            Ymax=[Ymax Y(ii,jj)];
        end
    end
end

temp = [Xmax;Ymax;dmax]';
temp(:,3)=temp(:,3).*(-1);
temp=sortrows(temp,3);
temp(:,3)=temp(:,3).*(-1);
Xmax(1,:)=temp(:,1);
Ymax(1,:)=temp(:,2);
dmax(1,:)=temp(:,3);
end

