% Teste de Similaridade de Artigos (test_minHash.m)
function test_minHash()
    % Carregar o dataset
    data = readtable('FakeNewsNet.csv', 'TextType', 'string');
    
    disp('Testando Similaridade entre Artigos:');
    
    % Escolhendo dois títulos de artigos do dataset para comparação
    title1 = data.title(1);  % Pega o título do primeiro artigo
    title2 = data.title(2);  % Pega o título do segundo artigo
    
    % Calculando a similaridade entre os dois títulos
    similarity = calculateSimilarity(title1, title2);  % Chama a função de similaridade
    
    % Imprime o resultado da similaridade
    fprintf('Similaridade entre os títulos: %d\n', similarity);
end
