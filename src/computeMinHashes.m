function minhashes = computeMinHashes(text, numHashes)
    % Divide o texto em palavras
    words = split(lower(text));  % Normaliza para minúsculas
    words = unique(words);       % Remove palavras duplicadas
    
    % Inicializa os valores mínimos para cada função de hash
    minhashes = inf(1, numHashes);
    
    % Calcula hashes para cada palavra
    for i = 1:length(words)
        wordHash = simpleHash(words{i}, numHashes);
        minhashes = min(minhashes, wordHash);
    end
end

function hashValues = simpleHash(word, numHashes)
    % Simplesmente calcula numHashes diferentes
    hashValues = zeros(1, numHashes);
    for i = 1:numHashes
        rng(i + sum(double(word)));  % Semente para variação
        hashValues(i) = randi([0, 1e6]);  % Valor hash
    end
end

function similarity = calculateJaccardSimilarity(title1, title2, numHashes)
    % Calcula os MinHashes dos textos
    minhashes1 = computeMinHashes(title1, numHashes);
    minhashes2 = computeMinHashes(title2, numHashes);
    
    % Calcula a similaridade Jaccard aproximada
    similarity = sum(minhashes1 == minhashes2) / numHashes;
end
