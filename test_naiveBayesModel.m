function test_naiveBayesModel()
% Vetor de teste para domínios confiáveis
testVector1 = [10, 20]; % Exemplo de vetor confiável
% Vetor de teste para domínios não confiáveis
testVector2 = [80, 90]; % Exemplo de vetor não confiável

% Fazer previsões
prediction1 = predictNaiveBayes(model, testVector1);
prediction2 = predictNaiveBayes(model, testVector2);

fprintf('Predição para vetor confiável: %d\n', prediction1);
fprintf('Predição para vetor não confiável: %d\n', prediction2);

end
