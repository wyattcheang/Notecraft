import Foundation

class YIN {
    private var sampleRate: Double
    private var bufferSize: Int
    private var threshold: Float
    
    init(sampleRate: Double, bufferSize: Int, threshold: Float = 0.1) {
        self.sampleRate = sampleRate
        self.bufferSize = bufferSize
        self.threshold = threshold
    }
    
    func detectPitch(data: [Float]) -> Double {
        let maxTau = bufferSize / 2
        var tauEstimate = 0
        var difference = [Float](repeating: 0.0, count: maxTau)
        
        // Step 1: Calculate the difference function
        for tau in 0..<maxTau {
            var sum: Float = 0.0
            for i in 0..<maxTau {
                if i + tau < data.count {
                    let delta = data[i] - data[i + tau]
                    sum += delta * delta
                }
            }
            difference[tau] = sum
        }
        
        // Step 2: Calculate the cumulative mean normalized difference function
        var cumulativeMeanNormalizedDifference = [Float](repeating: 0.0, count: maxTau)
        cumulativeMeanNormalizedDifference[0] = 1.0
        var runningSum: Float = 0.0
        
        for tau in 1..<maxTau {
            runningSum += difference[tau]
            cumulativeMeanNormalizedDifference[tau] = difference[tau] / (runningSum / Float(tau))
        }
        
        // Step 3: Absolute threshold
        for tau in 2..<maxTau {
            if cumulativeMeanNormalizedDifference[tau] < threshold {
                var tauIndex = tau
                while tauIndex + 1 < maxTau && cumulativeMeanNormalizedDifference[tauIndex + 1] < cumulativeMeanNormalizedDifference[tauIndex] {
                    tauIndex += 1
                }
                tauEstimate = tauIndex
                break
            }
        }
        
        // Step 4: Parabolic interpolation
        
        // Attempt to access array elements
        guard tauEstimate - 1 >= 0 && tauEstimate + 1 < cumulativeMeanNormalizedDifference.count else {
            return 0.0
        }

        let x0 = cumulativeMeanNormalizedDifference[tauEstimate - 1]
        let x1 = cumulativeMeanNormalizedDifference[tauEstimate]
        let x2 = cumulativeMeanNormalizedDifference[tauEstimate + 1]

        let numerator = x2 - x0
        let denominator = 2 * (2 * x1 - x2 - x0)
        let betterTau = Float(tauEstimate) + (numerator / denominator)
        return (sampleRate / Double(betterTau)).rounded()
    }
}
