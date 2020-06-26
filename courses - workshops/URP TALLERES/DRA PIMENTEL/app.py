import time
import io

from PIL import Image
from flask import Flask, request, make_response
import numpy as np
from itertools import product
from matplotlib import cm
import pylab as plt

def fractal_iteration(z, c, maxiter=256):
    for n in range(maxiter):
        if abs(z) > 2:
            return n
        z = z**2 + c
        
    return n

def fractal_set(w, h, c, maxiter=256):
    m = np.empty((h,w), dtype=np.uint8)
    
    for j, i in product(range(h), range(w)):
        z = (i - w/2) / (h/2) + (j - h/2) /(h/2)*1j
        m[j,i] = fractal_iteration(z, c, maxiter=maxiter)
    return m

def parse_request():
    w = request.args.get('w')
    w = int(w) if w else 600

    h = request.args.get('h')
    h = int(w) if h else 400

    cre = request.args.get('cre')
    cre = float(cre) if cre else -0.8

    cim = request.args.get('cim')
    cim = float(cim) if cim else 0.156
    
    camp = request.args.get('cmap')
    camp = str(camp) if camp else 'inferno'
    
    return w, h, cre, cim, camp

def gen_image(w, h, cre, cim, cmap):
    start = time.perf_counter()
    m = fractal_set(w, h, cre+cim*1j)
    end = time.perf_counter() - start
    print ('Made a {} x {} image in {} s'.format(w, h, end))
    
    image_data = np.empty((h, w, 3), dtype = np.uint8)
    colors = 255*np.array(getattr(cm, cmap).colors)
    
    for j, i in product(range(h), range(w)):
        image_data[j, i, :] = colors[m[j, i]]
        
    image = Image.fromarray(image_data, mode = 'RGB')
    stream =io.BytesIO()
    image.save(stream, format = 'png')
    stream.seek(io.SEEK_SET)
    return stream.read()



application = Flask('app')

@application.route('/')
def root():
    #return 'Request: {}, {}, {}, {}, {} '.format(*parse_request())
    image = gen_image(*parse_request())
    resp = make_response(image)
    resp.headers['Content-Type'] = 'image/png'
    return resp

if __name__ == '__main__':
    application.debug = True
    application.run()