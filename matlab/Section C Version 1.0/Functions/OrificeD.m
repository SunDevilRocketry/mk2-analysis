% Sutton and Biblarz
% experimentally determine Cd

function Do = OrificeD(Cd,mdot_ori,roe,dP)

Do = sqrt(mdot_ori.* (Cd.*pi./4.* sqrt(2.*roe.*dP)).^-1); 

end