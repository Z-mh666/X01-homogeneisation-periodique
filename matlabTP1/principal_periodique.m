% =====================================================
%
%
% une routine pour la mise en oeuvre des EF P1 Lagrange
% pour l'equation de Laplace suivante, avec conditions periodiques
% sur le maillage nom_maillage.msh
%
% | -div(A grad u ) u + u= f,   dans \Omega
% |         u periodique,   sur le bord
%
% =====================================================


% lecture du maillage et affichage
% ---------------------------------
nom_maillage = 'geomCarre_per.msh';
[Nbpt,Nbtri,Coorneu,Refneu,Numtri,Reftri,Nbaretes,Numaretes,Refaretes]=lecture_msh(nom_maillage);

% ----------------------
% calcul des matrices EF
% ----------------------

% declarations
% ------------
KK = sparse(Nbpt,Nbpt); % matrice de rigidite
MM = sparse(Nbpt,Nbpt); % matrice de rigidite
LL = zeros(Nbpt,1);     % vecteur second membre

% boucle sur les triangles
% ------------------------
for i=1:Nbtri
  % Coordonnees des sommets du triangles
  % A COMPLETER
  k = Numtri(i,1);
  l = Numtri(i,2);
  m = Numtri(i,3);
  
  S1 = Coorneu(k,:);
  S2 = Coorneu(l,:);
  S3 = Coorneu(m,:);
  % calcul des matrices elementaires du triangle l 
  
  %Kel=matK_elem(S1, S2, S3);
  Kel = matK_elem(S1,S2,S3);
           
  Mel = matM_elem(S1,S2,S3);
    
  % On fait l'assemmblage de la matrice globale et du second membre
  % A COMPLETER
  MM(k,k) += Mel(1,1);
  MM(l,l) += Mel(2,2);
  MM(m,m) += Mel(3,3);
  MM(k,l) += Mel(1,2);
  MM(k,m) += Mel(1,3);
  MM(l,m) += Mel(2,3);
  MM(l,k) += Mel(2,1);
  MM(m,k) += Mel(3,1);
  MM(m,l) += Mel(3,2);
  
  KK(k,k) += Kel(1,1);
  KK(l,l) += Kel(2,2);
  KK(m,m) += Kel(3,3);
  KK(k,l) += Kel(1,2);
  KK(k,m) += Kel(1,3);
  KK(l,m) += Kel(2,3);
  KK(l,k) += Kel(2,1);
  KK(m,k) += Kel(3,1);
  KK(m,l) += Kel(3,2);

end % for l

% Calcul du second membre L
% -------------------------
	% A COMPLETER
	% utiliser la routine f.m
FF = f(Coorneu(:,1),Coorneu(:,2));
LL = MM*FF;

% Projection sur l espace V_p
% ——————————————————�?
% matrice de projection 
PP = zeros(Nbpt,Nbpt);
PP(1,1) = 1;
PP(2,1) = 1;
PP(3,1) = 1;
PP(4,1) = 1;
num = 2;
for i=5:(Nbaretes/2+2)
  PP(i,num) = 1;
  num += 1;
endfor
num = 2;
for i=(Nbaretes/2+Nbaretes/4+1):-1:(Nbaretes/2+3)
  PP(i,num) = 1;
  num += 1;
endfor
for i=Nbaretes:-1:(Nbaretes/2+Nbaretes/4+2)
  PP(i,num) = 1;
  num += 1;
endfor
num = Nbaretes+1;
for i=(Nbaretes+1):Nbpt
  PP(i,num) = 1;
  num += 1;
endfor
  
AA = MM+KK;
AAp = PP' *AA*PP;
LLp = PP'*LL;

% inversion
% ----------
UUp = AAp\LLp;

% Expression de la solution dans toute la base
% ——————�?
UU = PP*UUp;

% visualisation
% -------------
affiche(UU, Numtri, Coorneu, sprintf('Periodique - %s', nom_maillage));

validation = 'non';
% validation
% ----------
if strcmp(validation,'non')
UU_exact = cos(pi*Coorneu(:,1)).*cos(2*pi*Coorneu(:,2));
% Calcul de l erreur L2
% A COMPLETER
errL2 = log(sqrt(UU'*MM*UU+UU_exact'*MM*UU_exact-2*UU'*MM*UU_exact)/sqrt(UU_exact'*MM*UU_exact))
err_L2 = [-2.1850,-3.5005,-4.8852,-6.7208];%stocker les erreurs L2 pour A = 1

figure(2)
plot([log(1/0.2),log(1/0.1),log(1/0.05),log(1/0.02)],err_L2);
xlabel('log(1/h)');
ylabel('erreur L2');
% Calcul de l erreur H1
% A COMPLETER
errH1 = log(sqrt(UU'*KK*UU+UU_exact'*KK*UU_exact-2*UU'*KK*UU_exact)/sqrt(UU_exact'*KK*UU_exact))
err_H1 = [-2.1776,-3.4338,-4.8443,-6.3562];  %stocker les erreurs H1 pour A = 1

figure(3)
plot([log(1/0.2),log(1/0.1),log(1/0.05),log(1/0.02)],err_L2);
xlabel('log(1/h)');
ylabel('erreur H1');
% attention de bien changer le terme source (dans FF)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                        fin de la routine
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

