% Dataset utilizado: 
%   Peso do cérebro x peso do corpo
% Disponível em:
%   http://people.sc.fsu.edu/~jburkardt/datasets/regression/x01.txt
% Acessado em:
%   23/11/2016
  
% x peso do cérebro
% y peso do corpo

% Diminuindo a grandeza utilizando a logarítimo na base 10 para ser possível analizar os dados,
% uma vez que a este dataset possui valores muito pequeno e muito grandes 
x = log10(load('./datasets/brain_body_weight/brain_weight')); 
y = log10(load('./datasets/brain_body_weight/body_weight'));

theta = [30,30];           % valores iniciais para coeficiente linear e angular 
alfa = 0.001;            % taxa de aprendizagem, resultado mais proximo do exato para 0.001
precisao = 0.000001;     % resultado mais proximo do exato para precisão 0.000001
max_iteracoes = 250000;  % número máximo de iterações, utilizado caso ocorra um loop infinito  



close all;               %fechar graficos
dg = DescidaGradiente(x,y,theta,alfa, precisao, max_iteracoes, 'log10 (peso do cérebro)','log10(peso do corpo)');
dg.executa;              %executa o metodo do gradiente 

% para exibir o historico dos testes, descomente a linha abaixo
% disp(dg.getHistorico);

data = dg.getHistorico;           % recuperando histórico de theta0 theta1 e custo
csvwrite("historico.cvs", data);  % escrevendo arquivo em formato cvs (pode ser aberto por uma gerenciador de planilhas)

dg.plotGrafico3d;                 % plotando gráfico tridimencional com eixos theta0 (x), theta1 (y) e custo (z)
figure;                           % permitindo abrir outra figura
dg.plotGraficoReta;               % plotando a reta obtida por theta0 e theta1
disp(dg.getUltimaExecucao);       % mostrando os dados da saída do algoritmo
disp(['Coeficiente de correlação Linear (r): ' num2str(dg.coeficienteCorrelacao)]);  % varia de -1 a 1, quanto mais próximo do módulo de 1 maior a correlação (valor calculado 0.95957)
disp(['Coeficiente de determinação (R2): ' num2str(dg.rQuadrado)]);                   % varia de 0 a 1, quanto mais próximo de 1 mais adequado é o modelo que descreve os dados