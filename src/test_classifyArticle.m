function test_classifyArticle()
    % Carregar o dataset
    data = readtable('FakeNewsNet.csv', 'TextType', 'string');
    
    disp('Testando Classificação de Artigos:');
    
    % Simulando a classificação dos primeiros 5 artigos no dataset
    for i = 1:5
        title = data.title(i);  % Pega o título do artigo
        url = data.news_url(i);  % Pega a URL do artigo
        result = classifyArticle(title, url);  % Chama a função de classificação
        fprintf('Título: %s -> Classificação: %d\n', title, result);  % 1 é real, 0 é fake
    end
end
