function [output_index] = look_up_table(a,b)

%For each element of vector 'a' you seek the nearest element of 'b' in
%terms of absolute difference. The following assumes that 'a' and 'b' are
%row vectors and that all the elements of 'a' are finite. It obtains the
%two row vectors 'd' and 'ib' of the same length as 'a'. Each element of
%'d' is the absolute difference between the corresponding element of 'a'
%and the nearest element of 'b'. Each element of 'ib' is the index with
%respect to the 'b' vector of that corresponding nearest 'b' element.

% Code taken from Roger Stafford
% http://www.mathworks.com/matlabcentral/newsreader/view_thread/243878

m = size(a,2); n = size(b,2);
 [c,p] = sort([a,b]);
 q = 1:m+n; q(p) = q;
 t = cumsum(p>m);
 r = 1:n; r(t(q(m+1:m+n))) = r;
 s = t(q(1:m));
 id = r(max(s,1));
 iu = r(min(s+1,n));
 [d,it] = min([abs(a-b(id));abs(b(iu)-a)]);
 ib = id+(it-1).*(iu-id);
 
 output_index=ib;
 
 
 