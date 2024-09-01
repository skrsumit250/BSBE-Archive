clc                                 % To clear the command window
clear                               % To clear the workspace
close all

%% Problem settings
lb = [-100 -100];                   % Lower bound
ub = [100 100];                     % Upper bound
prob = @SphereNew;                  % Fitness function

%% Algorithm parameters
Np = 10;                            % Population Size
T = 50;                             % No. of iterations

%% Starting of TLBO
f = NaN(Np,1);                      % Vector to store the fitness function value of the population members
BestFitIter = NaN(T+1,1);           % Vector to store the best fitness function value in every iteration

D = length(lb);                     % Determining the number of decision variables in the problem

P = repmat(lb,Np,1) + repmat((ub-lb),Np,1).*rand(Np,D);   % Generation of the initial population

for p = 1:Np
    f(p) = prob(P(p,:));            % Evaluating the fitness function of the initial population
end

BestFitIter(1) = min(f);

pts = 1000;

%% Creating values for contour plot
x = linspace(lb(1),ub(1),pts);
y = linspace(lb(2),ub(2),pts);
[x,y] = meshgrid(x,y);
for i = 1:pts
    for j = 1:pts
        z(i,j) = prob([x(i,j),y(i,j)]);
    end
end


%% Iteration loop
for t = 1: T
    
    for i = 1:Np
        %% Teacher Phase
        Xmean = mean(P);            % Determining mean of the population
        
        [~,ind] = min(f);           % Detemining the location of the teacher
        Xbest = P(ind,:);           % Copying the solution acting as teacher
        
        TF = randi([1 2],1,1);      % Generating either 1 or 2 randomly for teaching factor
        
        Xnew = P(i,:) + rand(1,D).*(Xbest - TF*Xmean);  % Generating the new solution
        
        Xnew = min(ub, Xnew);       % Bounding the violating variables to their upper bound
        Xnew = max(lb, Xnew);       % Bounding the violating variables to their lower bound
        
        fnew = prob(Xnew);          % Evaluating the fitness of the newly generated solution
        
        if (fnew < f(i))            % Greedy selection
            P(i,:) = Xnew;          % Include the new solution in population
            f(i) = fnew;            % Include the fitness function value of the new solution in population
        end
        
        
        %% Learner Phase
        
        p = randi([1 Np],1,1);      % Selection of random parter
        
        %% Ensuring that the current member is not the partner
        while i == p
            p = randi([1 Np],1,1);  % Selection of random parter
        end
        
        if f(i)< f(p)    % Select the appropriate equation to be used in Learner phase
            Xnew = P(i,:) + rand(1, D).*(P(i,:) - P(p,:));  % Generating the new solution
        else
            Xnew = P(i,:) - rand(1, D).*(P(i,:) - P(p,:));  % Generating the new solution
        end
        
        Xnew = min(ub, Xnew);       % Bounding the violating variables to their upper bound
        Xnew = max(lb, Xnew);       % Bounding the violating variables to their lower bound
        
        fnew = prob(Xnew);          % Evaluating the fitness of the newly generated solution
        
        if (fnew < f(i))            % Greedy selection
            P(i,:) = Xnew;          % Include the new solution in population
            f(i) = fnew;            % Include the fitness function value of the new solution in population
        end
              
    end
    
    BestFitIter(t+1) = min(f);      % Storing the best value of each iteration
    
    % convergence and variable space
    subplot(1,2,1)
    plot(0:t,BestFitIter(1:t+1),'b*');xlabel('Iteration');ylabel('Best fitness value')
    
    subplot(1,2,2)
    contour(x,y,z);
    hold on
    
    plot(P(:,1),P(:,2),'r*');xlabel('x_1');ylabel('x_2'); hold off
    
    drawnow;
end

[bestfitness,ind] = min(f)
bestsol = P(ind,:)