#!/usr/bin/env python
import os
for dirpath, _, filenames in os.walk('.'):
    for filename in filenames:
        if filename.startswith('TC'):
            oldFile = os.path.join(dirpath, filename)
            newFile = os.path.join(dirpath, filename.replace('TC', 'NL', 2))
            print newFile
            inFile = open(oldFile)
            outFile = open(newFile, 'w')
            replacements = {'TC':'NL'}
            for line in inFile:
                for src, target in replacements.iteritems():
                    line = line.replace(src, target)
                outFile.write(line)
            inFile.close()
            outFile.close()
            os.remove(oldFile)
