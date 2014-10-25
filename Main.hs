module Main where

import Control.Monad.State 

import Syntax
import Parser
import CompilerState
import Compiler
import qualified EVMCode as EVM 

compile :: FilePath -> FilePath -> IO ()
compile inPath outPath = do

  input <- readFile inPath
  let prog = parseString input
  putStrLn "Parsed program:"
  putStrLn (show prog)

  let ((labelSize,posCode), endState) 
          = runState (compileProgram prog) emptyState

  putStrLn "Error messages:"
  mapM_ putStrLn (csErrorMsgs endState)

  putStrLn "Generated extended EVM assembly:"
  putStrLn $ EVM.showPos posCode

  putStrLn $ "Label size: " ++ show labelSize

  let evmCode = snd $ unzip posCode
      bytecode = EVM.code2bytes evmCode
  putStrLn "Generated bytecode:"
  putStrLn $ show bytecode
  putStrLn $ "Bytecode size: " ++ show (length bytecode)

  let hexString = EVM.code2hexString evmCode
  putStrLn "As hex string:"
  putStrLn $ show hexString

  writeFile outPath hexString
  putStrLn "Bye!"

  
  
