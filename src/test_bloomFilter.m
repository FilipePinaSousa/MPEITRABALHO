% Teste de filtro Bloom (test_bloomFilter.m)
function test_bloomFilter()
    % Carregar o dataset
    data = readtable('FakeNewsNet.csv', 'TextType', 'string');
    
    % Criar filtro Bloom com 1000 slots
    bf = createBloomFilter(1000);
    hashFunc = @(x) simpleHash(x);  % Função de hash simples
    
    disp('Testando Filtro Bloom:');
    
    % Iterar sobre todos os artigos no dataset
    for i = 1:height(data)
        key = strcat(data.title(i), data.news_url(i));  % Combinação de título e URL
        [bf, isNew] = addToBloomFilter(bf, key, hashFunc);
        
        if ~isNew
            fprintf('Artigo duplicado: %s\n', data.title(i));
        else
            fprintf('Artigo único: %s\n', data.title(i));
        end
    end
end
