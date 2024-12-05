function findSimilarTitles(databaseFile)
    % Carregar os dados
    data = readtable(databaseFile, 'TextType', 'string');
    numHashes = 100;  % Número de funções de hash (ajustável)
    
    % Comparar todos os pares de títulos
    for i = 1:height(data)
        for j = i+1:height(data)
            similarity = calculateJaccardSimilarity(data.title(i), data.title(j), numHashes);
            fprintf('Similaridade entre os títulos:\n');
            fprintf('Título 1: %s\nTítulo 2: %s\nSimilaridade de Jaccard: %.2f\n\n', ...
                data.title(i), data.title(j), similarity);
        end
    end
end

function similarity = calculateJaccardSimilarity(title1, title2, numHashes)
    % Tokenizar os títulos
    tokens1 = split(lower(title1)); % Tokenização simples (palavras)
    tokens2 = split(lower(title2));
    
    % Criar o conjunto de tokens únicos
    set1 = unique(tokens1);
    set2 = unique(tokens2);
    
    % Unir os conjuntos para criar uma matriz de características
    allTokens = unique([set1; set2]);
    set1Bin = ismember(allTokens, set1);
    set2Bin = ismember(allTokens, set2);
    
    % Inicializar MinHash
    numTokens = length(allTokens);
    minHash1 = inf(1, numHashes);
    minHash2 = inf(1, numHashes);
    for k = 1:numHashes
        perm = randperm(numTokens);  % Permutação aleatória
        minHash1(k) = find(set1Bin(perm), 1 );  % Menor índice após permutação
        minHash2(k) = find(set2Bin(perm), 1 );
    end
    
    % Calcular a similaridade como a fração de hashes iguais
    similarity = sum(minHash1 == minHash2) / numHashes;
end
