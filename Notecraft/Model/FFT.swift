//
//  FFT.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 19/05/2024.
//

import Foundation
import Accelerate

class FFT {
    private var fftSetup: FFTSetup
    private var log2n: vDSP_Length
    private var n: Int
    private var nOver2: Int
    private var window: [Float]
    private var windowBuffer: UnsafeMutablePointer<Float>
    private var realp: UnsafeMutablePointer<Float>
    private var imagp: UnsafeMutablePointer<Float>
    
    init(sampleCount: Int, sampleRate: Double) {
        self.n = sampleCount
        self.nOver2 = sampleCount / 2
        self.log2n = vDSP_Length(log2(Float(sampleCount)))
        
        self.window = [Float](repeating: 0, count: sampleCount)
        vDSP_hann_window(&window, vDSP_Length(sampleCount), Int32(vDSP_HANN_NORM))
        
        self.windowBuffer = UnsafeMutablePointer<Float>.allocate(capacity: sampleCount)
        self.realp = UnsafeMutablePointer<Float>.allocate(capacity: nOver2)
        self.imagp = UnsafeMutablePointer<Float>.allocate(capacity: nOver2)
        
        fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))!
    }
    
    deinit {
        vDSP_destroy_fftsetup(fftSetup)
        windowBuffer.deallocate()
        realp.deallocate()
        imagp.deallocate()
    }
    
    func calculateMagnitudes(buffer: [Float]) -> [Float] {
        var output = [Float](repeating: 0.0, count: nOver2)
        
        var windowedBuffer = buffer
        vDSP_vmul(buffer, 1, window, 1, &windowedBuffer, 1, vDSP_Length(n))
        
        windowedBuffer.withUnsafeBufferPointer { (ptr: UnsafeBufferPointer<Float>) -> Void in
            let bufferPointer = UnsafeMutablePointer(mutating: ptr.baseAddress!)
            var splitComplex = DSPSplitComplex(realp: realp, imagp: imagp)
            bufferPointer.withMemoryRebound(to: DSPComplex.self, capacity: n) {
                vDSP_ctoz($0, 2, &splitComplex, 1, vDSP_Length(nOver2))
            }
            vDSP_fft_zrip(fftSetup, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))
            vDSP_zvmags(&splitComplex, 1, &output, 1, vDSP_Length(nOver2))
        }
        
        let normalizedMagnitudes = output.map { 10 * log10($0) }
        return normalizedMagnitudes
    }
    
    func frequency(at index: Int) -> Double {
        return Double(index) * (44100.0 / Double(n))
    }
}
