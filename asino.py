import random, sys

if __name__ == '__main__':
    args = list()
    if not sys.stdin.isatty():
        for line in sys.stdin:
            if line[-1] is '\n':
                line = line[:-1]
            args.append(line)
    else:
        args = sys.argv[1:]
    argRange = len(args)
    for i in range(argRange):
        print(str(i+1) + '.', args.pop(random.randrange(0, len(args))))    
