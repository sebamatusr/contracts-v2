/* External Imports */
import { BigNumber } from 'ethers'

export type SolidityFunctionParameter = string | number | BigNumber

export interface TestStep {
  functionName: string
  functionParams: Array<SolidityFunctionParameter | TestStep[]>
  returnStatus: boolean
  returnValues: any[]
}

export interface TestParameters {
  steps: TestStep[]
}

export interface TestDefinition {
  name: string
  preState?: {
    ExecutionManager?: any,
    StateManager?: any
  },
  parameters: Array<TestParameters | TestDefinition>,
  postState?: {
    ExecutionManager?: any,
    StateManager?: any
  },
}

export const isTestDefinition = (
  parameters: TestParameters | TestDefinition
): parameters is TestDefinition => {
  return (parameters as TestDefinition).name !== undefined
}