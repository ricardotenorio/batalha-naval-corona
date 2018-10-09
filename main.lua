-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

math.randomseed( os.time())


-------------------
-- Variáveis
-------------------

local navio = {  }
local tabuleiro = { }
local jogador = { }
-- fase 1 == posicionamento, 2 == batalha
local fase = 1

local tapListener

------------------- 
-- Objetos
-------------------

-- Classe navio
-- dano = 0, posicao = {}, tamanho = 0
-- construtor para a criação de um novo objeto
function navio:new()
	local obj = {}
	setmetatable( obj, self)
	self.__index = self
	obj.dano = 0
	obj.posicao = {}
	obj.tamanho = 0
	return obj
end



-- Classe tabuleiro
-- navios = {}, graficoLinha = {}, graficoColuna = {}, retangulos = {}
-- construtor
function tabuleiro:new ()
      obj = {}
      setmetatable(obj, self)
      self.__index = self
      obj.navios = {}
      obj.graficoLinha = {}
      obj.graficoColuna = {}
      obj.retangulos = {}
      return obj
end

-- Classe jogador
-- pontuacao = 0, tabuleiro = tabuleiro:new(), ia = false
-- construtor
function jogador:new()
	local obj = {}
	setmetatable( obj, self)
	self.__index = self
	obj.pontuacao = 0
	obj.tabuleiro = tabuleiro:new()
	obj.ia = false
	return obj
end



--------------------
-- Métodos
--------------------

-- desenha na tela o tabuleiro
function tabuleiro:desenharGrafico( )
	
	for i = 1, 9 do
		self.graficoLinha[i] = display.newLine( 0, display.contentHeight * i *.10, 
		display.contentWidth, display.contentHeight * i * .10 ) 

		self.graficoColuna[i] = display.newLine( display.contentWidth * i * .10, 0, 
		 display.contentWidth * i * .10, display.contentHeight) 
	end

end

-- desenha retângulos na tela para serem usados pelos listeners
function tabuleiro:desenharRetangulos( )
	local paint = { 0, .15, .60}

	for i=1,10 do
		
		self.retangulos[i] = {}
		for j=1, 10 do
			self.retangulos[i][j] = display.newRect( ( display.contentWidth / 20 * ( i + i - 1) ) , (  display.contentHeight / 20 * ( j + j - 1) ) , 
				display.contentWidth / 10, display.contentHeight / 10 )
			self.retangulos[i][j].fill = paint
			self.retangulos[i][j].alpha = .5
			self.retangulos[i][j].linha = i
			self.retangulos[i][j].coluna = j
			self.retangulos[i][j].ativo = true
			self.retangulos[i][j]:addEventListener ( "tap", tapListener )
		end

	end

end



-- atira na célula selecionada
function jogador:atirar( jogador2, linha, coluna)
	local acertou = false
	local pontuacao = self.pontuacao

	for i = 1, #jogador2.tabuleiro.navios do
		-- checa se o valor x e y estão entre as posições x1, x2 e y1, y2, respectivamente 

		if ( (linha >= jogador2.tabuleiro.navios[i].posicao[1] and linha <= jogador2.tabuleiro.navios[i].posicao[2])
			and 
			 (coluna >= jogador2.tabuleiro.navios[i].posicao[3] and coluna <= jogador2.tabuleiro.navios[i].posicao[4]) ) then
			acertou = true
			jogador2.tabuleiro.navios[i].dano = jogador2.tabuleiro.navios[i].dano + 1
			
			if ( jogador2.tabuleiro.navios[i].dano == jogador2.tabuleiro.navios[i].tamanho ) then
				pontuacao = pontuacao + jogador2.tabuleiro.navios[i].tamanho * 10
			end
		end
		
	end

	self.pontuacao = pontuacao

	return acertou

end



--------------------
-- Funções
--------------------

tapListener = function( event )
	event.target.fill = { 1, 0, 0}
end
local t = tabuleiro:new()
t:desenharGrafico()
t:desenharRetangulos()