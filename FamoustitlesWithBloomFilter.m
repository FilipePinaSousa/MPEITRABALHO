function FamoustitlesWithBloomFilter(databaseFile)
    % Processa um arquivo para identificar quais são as noticias mais famosas
    data = readtable(databaseFile, 'TextType', 'string');
    bf = createBloomFilter(100000); 
    
    % Iterar sobre os dados
    for i = 1:height(data)
        % Verificar valores ausentes
        if ismissing(data.title(i)) || ismissing(data.tweet_num(i))
            fprintf('Artigo inválido: Dados ausentes\n');
            continue;
        end
        
        % Criar uma chave única para o artigo
        key = strcat(data.title(i), num2str(data.tweet_num(i)));
        
        % Determinar se a notícia é famosa
        isFamous = data.tweet_num(i) > 50;
        
        % Se não for famosa, continue
        if ~isFamous
            fprintf('Notícia comum: %s\n', data.title(i));
            continue;
        end
        
        % Adicionar ao Bloom Filter
        try
            [bf, wasAlreadyFamous] = addToBloomFilter(bf, key);
        catch ME
            fprintf('Erro ao processar chave "%s": %s\n', key, ME.message);
            continue;
        end
        
        % Exibir resultados
        if ~wasAlreadyFamous
            fprintf('Nova notícia famosa: %s\n', data.title(i));
        else
            fprintf('Notícia já famosa: %s\n', data.title(i));
        end
    end
end

function bf = createBloomFilter(size)
    % Cria um vetor lógico para simular o Bloom Filter
    if size <= 0
        error('O tamanho do Bloom Filter deve ser positivo.');
    end
    bf = false(1, size);
end

function [bf, wasAlreadyFamous] = addToBloomFilter(bf, articleKey)
    % Adiciona uma chave ao Bloom Filter e verifica se já estava presente
    
    % Usa múltiplas funções hash para maior robustez
    hash1 = robustHash(articleKey);
    hash2 = robustHash(strcat(articleKey, 'salt')); % Segundo hash
    
    % Calcula os índices usando os valores hash e mod
    index1 = mod(hash1, length(bf)) + 1;
    index2 = mod(hash2, length(bf)) + 1;
    
    % Validar os índices
    if index1 < 1 || index1 > length(bf)
        fprintf('Erro: índice1 fora do intervalo (%d, tamanho: %d)\n', index1, length(bf));
        wasAlreadyFamous = false;
        return;
    end
    if index2 < 1 || index2 > length(bf)
        fprintf('Erro: índice2 fora do intervalo (%d, tamanho: %d)\n', index2, length(bf));
        wasAlreadyFamous = false;
        return;
    end
    
    % Verifica se ambas as posições já estão marcadas
    wasAlreadyFamous = bf(index1) && bf(index2);
    
    % Marca as posições no Bloom Filter
    bf(index1) = true;
    bf(index2) = true;
end

function hashValue = robustHash(inputString)
    % Nova função de hash baseada em soma de caracteres
    inputString = char(inputString); % Converte entrada para caractere
    hashValue = sum(double(inputString) .* (1:numel(inputString))); % Peso incremental
    hashValue = mod(abs(hashValue), 1e9); % Mantém valor dentro de um intervalo
end
