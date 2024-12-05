function processDuplicatesWithBloomFilter(databaseFile)
    % Processa um arquivo para identificar artigos duplicados usando Bloom Filter

    % Carregar dados do arquivo
    data = readtable(databaseFile, 'TextType', 'string');
    
    % Criar o Bloom Filter
    bf = createBloomFilter(1000); 
    
    % Iterar sobre os dados
    for i = 1:height(data)
        % Verificar valores ausentes
        if ismissing(data.title(i)) || ismissing(data.news_url(i))
            fprintf('Artigo inválido: Dados ausentes\n');
            continue;
        end
        
        % Criar uma chave única para o artigo (combinação de título e URL)
        key = strcat(data.title(i), data.news_url(i));
        
        % Adicionar ao Bloom Filter
        try
            [bf, isNew] = addToBloomFilter(bf, key);
        catch ME
            fprintf('Erro ao processar chave "%s": %s\n', key, ME.message);
            continue;
        end
        
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

function [bf, isNew] = addToBloomFilter(bf, articleKey)
    % Adiciona uma chave ao Bloom Filter e verifica se é nova
    
    % Usa função hash robusta (DataHash)
    hashValue = robustHash(articleKey);
    
    % Calcula o índice usando o valor hash
    index = mod(hashValue, length(bf)) + 1;  % Garantir índice no intervalo [1, length(bf)]
    
    % Verifica se o índice já estava marcado
    isNew = ~bf(index);
    
    % Marca o índice no Bloom Filter
    bf(index) = true;
end

function hashValue = robustHash(inputString)
    % Função hash robusta usando DataHash (ou método customizado)
    persistent md5;
    if isempty(md5)
        md5 = @(x) sum(double(x).^2); 
    end
    hashValue = abs(md5(inputString));
end
