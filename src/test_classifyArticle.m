% Teste de classificação de artigo (test_classifyArticle.m)
function test_classifyArticle()
    % Carregar o dataset
    data = readtable('FakeNewsNet.csv', 'TextType', 'string');
    
    disp('Testando Classificação de Artigos:');
    
    % Simulando a classificação dos primeiros 5 artigos no dataset
    for i = 1:5
        title = data.title(i);  % Pega o título do artigo
        result = classifyArticle(title);  % Chama a função de classificação
        fprintf('Título: %s -> Classificação: %d\n', title, result);  % 1 é real, 0 é fake
    end
end
