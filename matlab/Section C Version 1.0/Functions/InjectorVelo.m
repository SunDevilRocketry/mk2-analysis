function Vinj = InjectorVelo(mdot_ori,roe,Ao)

Vinj = mdot_ori./(roe.*Ao); 

end