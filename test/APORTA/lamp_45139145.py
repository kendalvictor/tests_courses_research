import numpy as np
import math
from numpy.linalg import matrix_rank
from scipy.linalg import svd
from scipy.sparse.linalg import svds

def lamp(X, CP, IM):
    """
        Resolucion reto4 
        Ejemplos dimensiones:
            X (165x13)
            CP (13x13)
            IM (13x2)
    """
    m, n = X.shape
    X = X.values
    M = CP.copy().values
    k = M.shape[1]
    R = np.zeros((m, 2))
    
    for i in range(m):
        aux = lambda j: X[i,:] - M[j,:]
        W = np.array([
            1 / (aux(j).transpose() @ aux(j)) for j in range(k)
        ])
        
        peso_total = W.sum()
        _M = lambda matrix: sum([W[u]*matrix[u] / peso_total for u in range(k)])
        Mx = _M(M)
        My = _M(IM)
        
        _calc = lambda C, Cx: np.array([W[z]*((C - Cx)[z,:]) for z in range(k)])
        A = _calc(M, Mx)
        B = _calc(IM, My)
        
        C = np.dot(A.transpose(),B)
        # posto = matrix_rank(C)

        U, D, V = svds(C, k=1)
        Raux = np.dot(U, V);
        R[i,:] = (np.dot((X[i,:]- Mx.transpose()),Raux))+ My.transpose()
        
    return R
   