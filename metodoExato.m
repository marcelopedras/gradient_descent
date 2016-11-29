% Dataset utilizado: 
%   Franquia de pizza
% Disponível em:
%   http://college.cengage.com/mathematics/brase/understandable_statistics/8e/students/datasets/slr/slr11.html
% Acessado em:
%   23/11/2016
  
% x taxa anual da franquia
% y custo inicial da franquia
% Escala 1* $1000 
%

%x = load('slr11l1.txt'); 
%y = load('slr11l2.txt');

x = log10(load('./datasets/brain_body_weight/brain_weight')); 
y = log10(load('./datasets/brain_body_weight/body_weight'));


%x = load('./datasets/brain_body_weight/brain_weight'); 
%y = load('./datasets/brain_body_weight/body_weight');


x0 = ones(length(x),1); %truque para notação matricial de forma a encontrar o coeficiente linear
x1 = x; 
X = [x0,x1];

%w = [w0;w1]
w = (pinv(X'*X))*X'*y;
%h = w(1) + (w(2)*x1);
h=X*w;
plot(x1,y,'xr');hold on; xlabel('Taxa de Custo Anual ($1000)'); ylabel('Custo para se iniciar a franquia ($1000)');
plot(x1, h);

disp(w);