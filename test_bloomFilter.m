function test_bloomFilter()
    % Teste para o Bloom Filter e suas operações
    fprintf('Iniciando testes do Bloom Filter...\n');

    % Teste 1: Criar Bloom Filter
    bfSize = 1000;
     bf = createBloomFilter(bfSize);
    assert(length(bf) == bfSize, 'Erro: O tamanho do Bloom Filter está incorreto.');
    fprintf('Teste 1: Criação do Bloom Filter - OK\n');

    % Teste 2: Adicionar uma chave nova
    articleKey1 = 'Noticia1_100';
    [bf, wasAlreadyFamous] = addToBloomFilter(bf, articleKey1);
    assert(~wasAlreadyFamous, 'Erro: A chave foi erroneamente detectada como já presente.');
    fprintf('Teste 2: Adição de chave nova - OK (wasAlreadyFamous = %d)\n', wasAlreadyFamous);

    % Teste 3: Re-adicionar a mesma chave
    [bf, wasAlreadyFamous] = addToBloomFilter(bf, articleKey1);
    assert(wasAlreadyFamous, 'Erro: A chave não foi detectada como já presente.');
    fprintf('Teste 3: Re-adicionar chave - OK (wasAlreadyFamous = %d)\n', wasAlreadyFamous);

    % Teste 4: Adicionar uma segunda chave única
    articleKey2 = 'Noticia2_200';
    [bf, wasAlreadyFamous] = addToBloomFilter(bf, articleKey2);
    assert(~wasAlreadyFamous, 'Erro: A segunda chave foi erroneamente detectada como já presente.');
    fprintf('Teste 4: Adição de segunda chave única - OK (wasAlreadyFamous = %d)\n', wasAlreadyFamous);

    % Teste 5: Verificar detecção incorreta (False Positives)
    % Simula uma chave não adicionada
    articleKey3 = 'Noticia3_300';
    [bf, wasAlreadyFamous] = addToBloomFilter(bf, articleKey3);
    if wasAlreadyFamous
        fprintf('Teste 5: Falso positivo detectado para chave "%s" (isso é esperado ocasionalmente em Bloom Filters).\n', articleKey3);
    else
        fprintf('Teste 5: Nenhum falso positivo detectado para chave "%s".\n', articleKey3);
    end

    % Teste 6: Verificar índices fora de intervalo (código robusto)
    try
        invalidKey = '';
        [~, wasAlreadyFamous] = addToBloomFilter(bf, invalidKey);
        fprintf('Teste 6: Manipulação de entrada inválida - OK (wasAlreadyFamous = %d)\n', wasAlreadyFamous);
    catch ME
        fprintf('Teste 6: Falha esperada para entrada inválida: %s\n', ME.message);
    end

    % Teste 7: Teste do fluxo completo com FamoustitlesWithBloomFilter
    try
        % Aqui você pode passar o caminho para um arquivo de dados de teste
        % Para fins de teste, o arquivo pode ser fictício ou pode ser um pequeno arquivo CSV com as colunas 'title' e 'tweet_num'.
        % Exemplo de chamada:
        FamoustitlesWithBloomFilter('FakeNewsNet.csv');
        fprintf('Teste 7: Teste completo de FamoustitlesWithBloomFilter - OK\n');
    catch ME
        fprintf('Teste 7: Erro no teste completo: %s\n', ME.message);
    end

    fprintf('Todos os testes foram concluídos!\n');
end
