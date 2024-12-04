% Teste de Similaridade de Artigos (test_minHash.m)
function test_minHash()
    % Carregar o dataset
    data = readtable('FakeNewsNet.csv', 'TextType', 'string');
    
    disp('Testando Similaridade entre Artigos:');
    
    % Escolhendo dois títulos de artigos do dataset para comparação
    title1 = data.title(1); 
    title2 = data.title(2);  
    
    % Número de funções de hash a serem usadas
    numHashes = 100;
    
    % Calculando a similaridade Jaccard entre os dois títulos
    similarity = calculateJaccardSimilarity(title1, title2, numHashes);
    
    % Imprime o resultado da similaridade
    fprintf('A similaridade Jaccard entre os títulos é: %.4f\n', similarity);
end
