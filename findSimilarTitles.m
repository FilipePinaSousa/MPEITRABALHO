function findSimilarTitles(databaseFile, threshold)
    % Carregar os dados
    data = readtable(databaseFile, 'TextType', 'string');
    numHashes = 100;  % Número de funções de hash
    
    % Comparar títulos
    for i = 1:height(data)
        for j = i+1:height(data)
            similarity = calculateJaccardSimilarity(data.title(i), data.title(j), numHashes);
            if similarity >= threshold
                fprintf('Títulos semelhantes (%.2f):\n%s\n%s\n\n', similarity, data.title(i), data.title(j));
            end
        end
    end
end
