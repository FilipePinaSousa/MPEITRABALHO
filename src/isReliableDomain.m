function isReliable = isReliableDomain(domain)
    % Lista de domínios confiáveis (exemplo)
    reliableDomains = ["bbc.com", "nytimes.com", "reuters.com", "cnn.com"];
    
    % Verificar se o domínio está na lista de confiáveis
    if any(strcmp(reliableDomains, domain))
        isReliable = 1;  % 1 indica domínio confiável
    else
        isReliable = 0;  % 0 indica domínio não confiável
    end
end
