classdef DescidaGradiente < handle
  properties(SetAccess=private)
    alfa;
    vetor_thetas_ini;
    numero_iteracoes;
    vetor_X;
    vetor_y;
    tamanho_amostra;
    historico;
    hist_ultima_exec;
    precisao;
    max_iteracoes;
    x_label;
    y_label;
  end
  
  methods
    function this = DescidaGradiente(vetor_x, vetor_y, vetor_thetas, alfa, precisao, max_iteracoes, x_label, y_label)
      % configurando x0 como 1 a fim de encontrar o coeficiente linear 
      % (isso e necessario para calcular o custo (metodo calculaCusto)
      this.vetor_X          = [ones(length(vetor_x),1), vetor_x];
      this.vetor_y          = vetor_y;
      this.alfa             = alfa;
      this.vetor_thetas_ini = vetor_thetas;
      this.tamanho_amostra  = length(this.vetor_y);      
      this.historico        = [];
      this.x_label          = x_label;
      this.y_label          = y_label;
      this.precisao         = precisao;
      this.max_iteracoes    = max_iteracoes;
    end
    
    
  
    function [thetas, custo] = executa(this)
        thetas = this.vetor_thetas_ini;
        custo = 0;
        iter_count = 0;
        
        %pare se o numero maximo de iteracoes for alcancado
        while(iter_count < this.max_iteracoes)
            x = this.vetor_X(:,2);
            
            % função da reta
            h = thetas(1) + (thetas(2)*x);

            % atualizando theta zero e um, alfa anterior menos a taxa de aprendizagem vezes o erro médio
            
            gradiente0 = (1/this.tamanho_amostra) * sum(h-this.vetor_y);
            gradiente1 = (1/this.tamanho_amostra) * sum((h - this.vetor_y) .* x);
            
            %calculando o custo para os novos thetas
            theta_zero = thetas(1) - this.alfa * gradiente0;
            theta_um   = thetas(2) - this.alfa * gradiente1;
            thetas = [theta_zero; theta_um];
            
            % a cada 200 iteracoes colete dados para formar o historico
            if(mod(iter_count, 200) == 0)
              custo = this.calculaCusto(thetas);
              this.historico = [this.historico; thetas(1), thetas(2), custo];
            end
            
            ++iter_count;
            % pare se a precisao tangente da funcao de custo em relalacao a theta_zero e theta_um ( J(theta_zero, theta_um) )
            % esta proxima de zero          
            if (abs(gradiente0) <= this.precisao) && (abs(gradiente1) <= this.precisao)                        
              break;            
            end
        end
        
        custo = this.calculaCusto(thetas);
        % extraindo estatísticas para refinamento de parâmetros        
        this.hist_ultima_exec = struct('theta_zero',  thetas(1), 'theta_um',  thetas(2), 'custo', custo, 'alfa', this.alfa, 'iteracoes', iter_count, 'precisao', this.precisao);
        % adicionando a ultima iteracao ao historico
        this.historico = [this.historico; thetas(1), thetas(2), custo];      
      end
  
    function historico = getHistorico(this)
      historico = this.historico;  
    end
  
    function ultima_exec = getUltimaExecucao(this)
      ultima_exec = this.hist_ultima_exec;
    end
  
    function this = setAlfa(this, alfa)
      this.alfa = alfa;
    end
  
    function this = setMaxIteracoes(this, max_iter)
      this.max_iteracoes = max_iter;
    end
  
    function this = setThetas(this, theta_zero, theta_um)
      this.vetor_thetas_ini = [theta_zero, theta_um];
    end
    
    function r_quadrado = rQuadrado(this)
      x = this.vetor_X(:,2);
      y = this.vetor_y;      
      yCalculado = this.hist_ultima_exec.theta_zero + this.hist_ultima_exec.theta_um*x;
      yMedia     = mean(this.vetor_y);
      
      r_quadrado = sum((yCalculado - yMedia).^2)/sum((y-yMedia).^2);
    end
    
    function r = coeficienteCorrelacao(this)
      x = this.vetor_X(:,2);
      y = this.vetor_y;  
      r = corr(x,y);
    end
  
    function plotGraficoReta(this)
      thetas = [this.hist_ultima_exec.theta_zero; this.hist_ultima_exec.theta_um];
      h = this.vetor_X*thetas;
      plot(this.vetor_X(:,2),this.vetor_y,'xr');
      title(['Regressão Linear ( y = ' num2str(thetas(1)) 'x + ' num2str(thetas(2)) ' )' ]);
      xlabel(this.x_label);
      ylabel(this.y_label);  
      hold on;          
      plot(this.vetor_X(:,2), h);
    end
  
    function plotGrafico3d(this)
      % descomente esta linha caso tenha problemas com aceleração gráfica na hora de interagir com os gráficos no octave
      % graphics_toolkit gnuplot;
      
      theta0 = this.hist_ultima_exec.theta_zero;
      theta1 = this.hist_ultima_exec.theta_um;
      theta0_ini = abs(this.vetor_thetas_ini(1))+1; %garantindo que nao seja 0;
      theta1_ini = abs(this.vetor_thetas_ini(2))+1; %%garantindo que nao seja 0;
      custos_J = zeros(50, 50);                                       % iniciando a matriz para interpolação de dados
      valores_theta0 = linspace(-theta0_ini*abs(theta0), theta0_ini*abs(theta0),50);  % crie 50 valores para theta0 entre -theta0 inicial e +theta0 inicial vezes o valor de theta0  
      valores_theta1 = linspace(-theta1_ini*abs(theta1), theta1_ini*abs(theta1) ,50); % crie 50 valores para theta1 entre -theta1 inicial e +theta1 inicial vezes o valor de theta1
      
      %interpolando cada valor de theta0 e theta1 e configurando seu custo
      for i = 1:length(valores_theta0)
        for j = 1:length(valores_theta1)
          thetas = [valores_theta0(i); valores_theta1(j)];
          custos_J(i,j) = this.calculaCusto(thetas);
        end
      end     
      
      % Necessário para que os eixos não fiquem invertidos no gráfico
      custos_J = custos_J';
      
      % Plotando um gráfico de superfície
      surf(valores_theta0, valores_theta1, custos_J);
      hold on;
      plot3(this.historico(:,1),this.historico(:,2),this.historico(:,3)','-w*..');
      
      % Configurando as legendas dos eixos
      title(['Custo da função objetivo (min(J(\theta_0, \theta_1)) -> \theta_0 = ' num2str(theta0) ' e \theta_1 = ' num2str(theta1) ' )']);
      xlabel('\theta_0');
      ylabel('\theta_1');
      zlabel('J(\theta_0, \theta_1)');
    end
  end
  
  methods(SetAccess=private)
     function custo = calculaCusto(this, thetas)
      custo = 0;
      
      % função da reta
      % y calculado pelo algoritmo
      y_calculado = this.vetor_X*thetas;              
      
      % calculando o erro quadrático 
      erro_quadratico   = (y_calculado - this.vetor_y).^2;
      
      % calculando custo da função objetivo para regressão linear
      custo = (1/(2*this.tamanho_amostra)) * sum(erro_quadratico);
     end  
  end
end