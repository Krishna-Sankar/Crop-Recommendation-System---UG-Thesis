function[cm] = conmat(true_label,estim_label)

classlist = unique(true_label);

L = length(classlist);
cm = zeros(L,L);

for i = 1:L
    for j = 1:L
        m = (estim_label == classlist(i) ...
           & true_label  == classlist(j));
        cm(i,j) = sum(m);
    end
end

cm = cm';
end