function RegNet = PANDA(RegNet, GeneCoReg, TFCoop, alpha)
% Description:
%              PANDA infers a gene regulatory network from gene expression
%              data, motif prior, and PPI between transcription factors
%
% Inputs:
%               RegNet   : motif prior of gene-TF regulatory network
%               GeneCoReg: gene-gene co-regulatory network
%               TFCoop   : PPI binding between transcription factors
%
% Outputs:
%               RegNet   : inferred gene-TF regulatory network
%
% Authors:
%               Kimberley Glass
%
% Publications:
%               https://doi.org/10.1371/journal.pone.0064832 
    [NumTFs, NumGenes] = size(RegNet);
    disp('Learning Network!');
    tic;
    step = 0;
    hamming = 1;
    while hamming > 0.001
        R = Tfunction(TFCoop, RegNet);
        A = Tfunction(RegNet, GeneCoReg);
        W = (R + A) * 0.5;
        hamming = mean(abs(RegNet(:) - W(:)));
        RegNet = (1 - alpha) * RegNet + alpha * W;

        if hamming > 0.001
            PPI = Tfunction(RegNet);
            PPI = UpdateDiagonal(PPI, NumTFs, alpha, step);
            TFCoop = (1 - alpha) * TFCoop + alpha * PPI;

            CoReg2 = Tfunction(RegNet');
            CoReg2 = UpdateDiagonal(CoReg2, NumGenes, alpha, step);
            GeneCoReg = (1 - alpha) * GeneCoReg + alpha * CoReg2;
        end

        disp(['Step#', num2str(step), ', hamming=', num2str(hamming)]);
        step = step + 1;
        clear R A W PPI CoReg2;  % release memory for next step
    end
    runtime = toc;
    fprintf('Running PANDA on %d Genes and %d TFs took %f seconds!\n', NumGenes, NumTFs, runtime);
end
