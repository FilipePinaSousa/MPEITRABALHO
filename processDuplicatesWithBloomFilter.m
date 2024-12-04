function processDuplicatesWithBloomFilter(databaseFile)
    % Processa um arquivo para identificar artigos duplicados usando Bloom Filter

    % Carregar dados do arquivo
    data = readtable(databaseFile, 'TextType', 'string');
    
    % Criar o Bloom Filter
    bf = createBloomFilter(1000);  % Bloom Filter com 1000 slots
    
    % Definir uma função hash simples
    hashFunc = @(x) simpleHash(x);
    
    % Iterar sobre os dados
    for i = 1:height(data)
        % Criar uma chave única para o artigo (combinação de título e URL)
        key = strcat(data.title(i), data.news_url(i));
        
        % Adicionar ao Bloom Filter
        [bf, isNew] = addToBloomFilter(bf, key, hashFunc);
        
        % Exibir resultados
        if ~isNew
            fprintf('Artigo duplicado: %s\n', data.title(i));
        else
            fprintf('Artigo único: %s\n', data.title(i));
        end
    end
end

function bf = createBloomFilter(size)
    % Cria um vetor lógico para simular o Bloom Filter
    bf = false(1, size);
end

function [bf, isNew] = addToBloomFilter(bf, articleKey, hashFunction)
    % Adiciona uma chave ao Bloom Filter e verifica se é nova

    % Calcula o índice usando a função hash
    index = mod(hashFunction(articleKey), length(bf)) + 1;
    
    % Verifica se o índice já estava marcado
    isNew = ~bf(index);
    
    % Marca o índice no Bloom Filter
    bf(index) = true;
end

function hashValue = simpleHash(articleID)
    % Função hash simples baseada na soma dos códigos ASCII
    hashValue = sum(double(articleID));
end
